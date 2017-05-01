//
//  AuthenticationCoordinators.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 24.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow

struct AuthenticationCoordinator : ApplicationCoordinatorType {
	let controller: UIViewController
	let window: UIWindow
	
	init(window: UIWindow, controller: UIViewController) {
		self.window = window
		self.controller = controller
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		if let state = handleBase(action: action, flowController: flowController, currentViewController: controller) {
			return state
		}
		
		switch action {
		case UIAction.showFirebaseRegistrationController:
			let registrationController = AuthenticationController(viewModel: AuthenticationViewModel(flowController: flowController, mode: .registration))
            registrationController.modalTransitionStyle = .flipHorizontal
			let coordinator = FirebaseRegistrationCoordinator(parent: self, controller: registrationController)
			controller.present(coordinator.controller, animated: true, completion: nil)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		case UIAction.showTasksListController:
			let coordinator = TasksCoordinator(window: window, flowController: flowController)
			set(newRootController: coordinator.navigationController)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		default: return .empty()
		}
	}
}

struct FirebaseRegistrationCoordinator : ApplicationCoordinatorType {
	let parent: ApplicationCoordinatorType
	let window: UIWindow
	let controller: UIViewController
	
	init(parent: ApplicationCoordinatorType, controller: UIViewController) {
		self.parent = parent
		self.window = parent.window
		self.controller = controller
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		if let state = handleBase(action: action, flowController: flowController, currentViewController: controller) {
			return state
		}
		
		switch action {
		case UIAction.dismissFirebaseRegistrationController:
			controller.dismiss(animated: true, completion: nil)
			return .just(flowController.currentState.state.mutation.new(coordinator: parent))
		default: return .empty()
		}
	}
}
