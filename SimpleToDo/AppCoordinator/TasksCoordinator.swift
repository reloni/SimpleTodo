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
	let navigationController: TasksListNavigationController
	
	init(window: UIWindow, flowController: RxDataFlowController<AppState>) {
		self.window = window
		
		navigationController = TasksListNavigationController()
		let viewModel = TasksViewModel(flowController: flowController)
		navigationController.pushViewController(TasksController(viewModel: viewModel), animated: false)
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
		case GeneralAction.logOff:
			let coordinator = SignInCoordinator(window: window, controller: SignInController(viewModel: SignInViewModel(flowController: flowController)))
			set(newRootController: coordinator.controller!)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		default: return .empty()
		}
	}
}
