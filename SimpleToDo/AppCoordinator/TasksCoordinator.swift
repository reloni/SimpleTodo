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
	let parent: ApplicationCoordinatorType
	let navigationController: TasksListNavigationController
	
    init(parent: ApplicationCoordinatorType, flowController: RxDataFlowController<AppState>) {
		self.parent = parent
		
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
		default: return .empty()
		}
	}
}
