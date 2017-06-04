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

final class AuthenticationViewModel: ViewModelType {
	enum Mode {
		case logIn
		case registration
	}
	
	let flowController: RxDataFlowController<RootReducer>
	
	let mode: Mode
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in
			guard let object = self else { return }
			object.flowController.dispatch(UIAction.showSnackView(error: $0.error, hideAfter: 4))
		})
	}()
	
	init(flowController: RxDataFlowController<RootReducer>, mode: Mode) {
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
			flowController.dispatch(UIAction.showSpinner)
			flowController.dispatch(RxCompositeAction(actions: [AuthenticationAction.logIn(email, password),
			                                                    SynchronizationAction.updateConfiguration,
			                                                    UIAction.showTasksListController,
			                                                    PushNotificationsAction.promtForPushNotifications]))
			flowController.dispatch(UIAction.hideSpinner)
		case .registration:
			flowController.dispatch(UIAction.showSpinner)
			flowController.dispatch(RxCompositeAction(actions: [AuthenticationAction.register(email, password), UIAction.dismissFirebaseRegistrationController]))
			flowController.dispatch(UIAction.hideSpinner)
		}

	}
	
	func performSupplementalAction() {
		switch mode {
		case .logIn: flowController.dispatch(UIAction.showFirebaseRegistrationController)
		case .registration: flowController.dispatch(UIAction.dismissFirebaseRegistrationController)
		}
	}
	
	func resetPassword(email: String) {
		flowController.dispatch(AuthenticationAction.resetPassword(email))
	}
}