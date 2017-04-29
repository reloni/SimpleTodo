//
//  TasksCoordinator.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 02.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow

struct TasksCoordinator : ApplicationCoordinatorType {
	let window: UIWindow
	let navigationController: GenericNavigationController
	
	init(window: UIWindow, flowController: RxDataFlowController<AppState>) {
		self.window = window
		let viewModel = TasksViewModel(flowController: flowController)
		navigationController = GenericNavigationController(rootViewController: TasksController(viewModel: viewModel))
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		switch action {
		case TaskListAction.showEditTaskController(let task):
			let viewModel = EditTaskViewModel(task: task, flowController: flowController)
			navigationController.pushViewController(EditTaskController(viewModel: viewModel), animated: true)
			return .just(flowController.currentState.state)
		case EditTaskAction.dismisEditTaskController:
			navigationController.popViewController(animated: true)
			return .just(flowController.currentState.state)
		case GeneralAction.returnToRootController:
			let coordinator = AuthenticationCoordinator(window: window, controller: AuthenticationController(viewModel: AuthenticationViewModel(flowController: flowController,
			                                                                                                                                    mode: .logIn)))
			set(newRootController: coordinator.controller!)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		case GeneralAction.error(let error):
			showAlert(in: navigationController.visibleViewController!, with: error)
			return .just(flowController.currentState.state)
		case GeneralAction.showSettingsController:
			let controller = GenericNavigationController(rootViewController: SettingsController(viewModel: SettingsViewModel(flowController: flowController)))
			let coordinator = SettingsCoordinator(parent: self,
			                                      controller: controller)
			navigationController.present(coordinator.controller, animated: true, completion: nil)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		default: return .empty()
		}
	}
}
