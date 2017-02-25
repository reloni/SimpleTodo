//
//  AuthenticationCoordinators.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 24.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

protocol ApplicationCoordinatorType {
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType>
}

struct SignInCoordinator : ApplicationCoordinatorType {
	let controller: UIViewController?
	let window: UIWindow
	
	init(window: UIWindow, controller: UIViewController? = nil) {
		self.window = window
		self.controller = controller
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		switch action {
		case GeneralAction.showRootController:
			window.rootViewController = SignInController(viewModel: SignInViewModel(flowController: flowController))
			window.makeKeyAndVisible()
			return .just(flowController.currentState.state.mutation.new(coordinator: SignInCoordinator.init(window: window, controller: window.rootViewController)))
		case SignInAction.showFirebaseRegistration:
			let coordinator = FirebaseRegistrationCoordinator(parent: self)
			controller!.present(coordinator.controller, animated: true, completion: nil)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		case GeneralAction.error(let error): return UICoordinator.showAlert(in: controller!, with: error, currentState: flowController.currentState.state)
		default: return .empty()
		}
	}
}

struct FirebaseRegistrationCoordinator : ApplicationCoordinatorType {
	let parent: ApplicationCoordinatorType
	let controller: UIViewController
	
	init(parent: ApplicationCoordinatorType, controller: UIViewController = FirebaseRegistrationController()) {
		self.parent = parent
		self.controller = controller
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		switch action {
		case SignInAction.dismissFirebaseRegistration:
			controller.dismiss(animated: true, completion: nil)
			return .just(flowController.currentState.state.mutation.new(coordinator: parent))
		case GeneralAction.error(let error): return UICoordinator.showAlert(in: controller, with: error, currentState: flowController.currentState.state)
		default: return .empty()
		}
	}
}
