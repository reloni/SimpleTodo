//
//  AuthenticationCoordinators.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 24.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import RxSwift
import RxDataFlow

struct AuthenticationCoordinator : ApplicationCoordinatorType {
	let controller: UIViewController
	let window: UIWindow
	let flowController: RxDataFlowController<AppState>
	
	init(window: UIWindow, controller: UIViewController, flowController: RxDataFlowController<AppState>) {
		self.window = window
		self.controller = controller
		self.flowController = flowController
	}
	
	func handle(_ action: RxActionType) -> Observable<RxStateMutator<AppState>> {
		if let state = handleBase(action: action, currentViewController: controller) {
			return state
		}
		
		switch action {
		case UIAction.showFirebaseRegistrationController:
			let registrationController = AuthenticationController(viewModel: AuthenticationViewModel(flowController: flowController, mode: .registration))
            registrationController.presentationController?.delegate = registrationController
			let coordinator = FirebaseRegistrationCoordinator(parent: self, controller: registrationController, flowController: flowController)
			controller.present(coordinator.controller, animated: true, completion: nil)
			return .just({ $0.mutation.new(coordinator: coordinator) })
		case UIAction.showTasksListController:
			let coordinator = TasksCoordinator(window: window, flowController: flowController)
			set(newRootController: coordinator.navigationController)
			return .just({ $0.mutation.new(coordinator: coordinator) })
		default: return .empty()
		}
	}
}

struct FirebaseRegistrationCoordinator : ApplicationCoordinatorType {
	let parent: ApplicationCoordinatorType
	let window: UIWindow
	let controller: UIViewController
	let flowController: RxDataFlowController<AppState>
	
	init(parent: ApplicationCoordinatorType, controller: UIViewController, flowController: RxDataFlowController<AppState>) {
		self.parent = parent
		self.window = parent.window
		self.controller = controller
		self.flowController = flowController
	}
	
	func handle(_ action: RxActionType) -> Observable<RxStateMutator<AppState>> {
		if let state = handleBase(action: action, currentViewController: controller) {
			return state
		}
		
		switch action {
		case UIAction.dismissFirebaseRegistrationController:
			controller.dismiss(animated: true, completion: nil)
			let parentCoordinator = parent
			return .just({ $0.mutation.new(coordinator: parentCoordinator) })
		default: return .empty()
		}
	}
}
