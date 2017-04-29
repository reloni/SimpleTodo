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
		if let state = handleBase(action: action, flowController: flowController, currentViewController: navigationController) {
			return state
		}
		
		switch action {
		case UIAction.showEditTaskController(let task):
			let viewModel = EditTaskViewModel(task: task, flowController: flowController)
			navigationController.pushViewController(EditTaskController(viewModel: viewModel), animated: true)
			return .just(flowController.currentState.state)
		case UIAction.dismisEditTaskController:
			navigationController.popViewController(animated: true)
			return .just(flowController.currentState.state)
		case UIAction.showSettingsController:
			let controller = GenericNavigationController(rootViewController: SettingsController(viewModel: SettingsViewModel(flowController: flowController)))
			
			let transitionDelegate = TransitionDelegate(controller: SlidePresentAnimationController(mode: .toRight))
			controller.transitioningDelegate = transitionDelegate
			
			let coordinator = SettingsCoordinator(parent: self,
			                                      controller: controller)
			navigationController.present(coordinator.controller, animated: true, completion: nil)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		default: return .empty()
		}
	}
}
