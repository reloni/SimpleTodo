//
//  AuthenticationViewModel.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 25.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift
import RxDataFlow

final class AuthenticationViewModel {
	enum Mode {
		case logIn
		case registration
	}
	
	let flowController: RxDataFlowController<AppState>
	
	let mode: Mode
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in
			guard let object = self else { return }
			object.flowController.dispatch(GeneralAction.error($0.error))
		})
	}()
	
	init(flowController: RxDataFlowController<AppState>, mode: Mode) {
		self.flowController = flowController
		self.mode = mode
	}
	
	var actionButtonTitle: String {
		switch mode {
		case .logIn: return "Login"
		case .registration: return "Registration"
		}
	}
	
	var supplementalButtonTitle: String {
		switch mode {
		case .logIn: return "Registration"
		case .registration: return "Cancel"
		}
	}
	
	var email: String {
		guard mode == .logIn else { return "" }
		return Keychain.userEmail
	}
	
	var password: String {
		guard mode == .logIn else { return "" }
		return Keychain.userPassword
	}
	
	func performAction(email: String, password: String) {
		switch mode {
		case .logIn:
			flowController.dispatch(RxCompositeAction(actions: [AuthenticationAction.logIn(email, password),
			                                                    AuthenticationAction.showTasksListController,
			                                                    PushNotificationsAction.promtForPushNotifications]))
		case .registration:
			flowController.dispatch(RxCompositeAction(actions: [AuthenticationAction.register(email, password), AuthenticationAction.dismissFirebaseRegistration]))
		}

	}
	
	func performSupplementalAction() {
		switch mode {
		case .logIn: flowController.dispatch(AuthenticationAction.showFirebaseRegistration)
		case .registration: flowController.dispatch(AuthenticationAction.dismissFirebaseRegistration)
		}
	}
	
	func resetPassword(email: String) {
		flowController.dispatch(AuthenticationAction.resetPassword(email))
	}
}
