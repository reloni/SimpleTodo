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
	
	let flowController: RxDataFlowController<AppState>
	
	let mode: Mode
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in
			guard let object = self else { return }
			object.flowController.dispatch(UIAction.showSnackView(error: $0.error, hideAfter: 4))
		})
	}()
	
	init(flowController: RxDataFlowController<AppState>, mode: Mode) {
		self.flowController = flowController
		self.mode = mode
		showPasswordOrRegistrationEnterSubject = BehaviorSubject(value: mode == .registration)
		showAuthenticationTypesSubject = BehaviorSubject(value: mode == .logIn)
	}
	
	private let showAuthenticationTypesSubject: BehaviorSubject<Bool>
	var showAuthenticationTypes: Observable<Bool> { return showAuthenticationTypesSubject.asObservable() }
	
	private let showPasswordOrRegistrationEnterSubject: BehaviorSubject<Bool>
	var showPasswordOrRegistrationEnter: Observable<Bool> { return showPasswordOrRegistrationEnterSubject.asObservable() }
	
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
	
	var dbAuthentication: (email: String, password: String)? {
		guard case let AuthenticationType.db(email, password)? = Keychain.authenticationType else { return nil }
		return (email: email, password: password)
	}
	
	var email: String {
		guard mode == .logIn else { return "" }
		return dbAuthentication?.email ?? ""
	}
	
	var password: String {
		guard mode == .logIn else { return "" }
		return dbAuthentication?.password ?? ""
	}
	
	func toggleShowPasswordOrRegistrationEnter() {
		showPasswordOrRegistrationEnterSubject.onNext(!((try? showPasswordOrRegistrationEnterSubject.value()) ?? true))
	}
	
	func authenticateWithFacebook() {
		authenticate(authType: AuthenticationType.facebook)
	}
	
	func authenticateWithGoogle() {
		authenticate(authType: AuthenticationType.google)
	}
	
	func update(host: String) {
		flowController.dispatch(SynchronizationAction.updateHost(host))
	}
	
	private func authenticate(authType: AuthenticationType) {
		let action = RxCompositeAction(actions: [AuthenticationAction.logIn(authType),
		                            UIAction.showSpinner,
		                            SynchronizationAction.updateConfiguration,
		                            UIAction.showTasksListController,
		                            UIAction.hideSpinner,
		                            PushNotificationsAction.promptForPushNotifications,
									authType.analyticalLogInAction()],
		                  fallbackAction: UIAction.hideSpinner)
		flowController.dispatch(action)
	}
	
	func performAction(email: String, password: String) {
		switch mode {
		case .logIn:
			flowController.dispatch(UIAction.showSpinner)
			authenticate(authType: AuthenticationType.db(email: email, password: password))
			flowController.dispatch(UIAction.hideSpinner)
		case .registration:
			flowController.dispatch(UIAction.showSpinner)
			flowController.dispatch(RxCompositeAction(actions: [AuthenticationAction.register(email, password),
			                                                    SystemAction.clearKeychain,
			                                                    UIAction.dismissFirebaseRegistrationController]))
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

extension AuthenticationType {
	func analyticalLogInAction() -> AnalyticalAction {
		switch self {
		case .db: return AnalyticalAction.logIn(.password)
		case .facebook: return AnalyticalAction.logIn(.facebook)
		case .google: return AnalyticalAction.logIn(.google)
		}
	}
}
