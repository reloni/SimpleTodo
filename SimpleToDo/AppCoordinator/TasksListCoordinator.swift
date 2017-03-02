//
//  TasksListCoordinator.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 02.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow

struct TasksListCoordinator : ApplicationCoordinatorType {
	let parent: ApplicationCoordinatorType
	let navigationController: TasksListNavigationController
	
	init(parent: ApplicationCoordinatorType) {
		self.parent = parent
		
		navigationController = TasksListNavigationController()
		navigationController.pushViewController(TasksController(), animated: false)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		return .empty()
	}
}
