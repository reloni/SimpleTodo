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
	
	init(parent: ApplicationCoordinatorType) {
		self.parent = parent
		
		navigationController = TasksListNavigationController()
		navigationController.pushViewController(TasksController(), animated: false)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		switch action {
		case TaskListAction.showEditTaskController(let task):
			navigationController.pushViewController(EditTaskController(task: task), animated: true)
			return .just(flowController.currentState.state)
		case EditTaskAction.dismisEditTaskController:
			navigationController.popViewController(animated: true)
			return .just(flowController.currentState.state)
		default: return .empty()
		}
	}
}
