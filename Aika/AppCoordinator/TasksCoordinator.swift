//
//  TasksCoordinator.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 02.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow
import UIKit

struct TasksCoordinator : ApplicationCoordinatorType {
	let window: UIWindow
	let navigationController: GenericNavigationController
	let flowController: RxDataFlowController<RootReducer>
	
	init(window: UIWindow, flowController: RxDataFlowController<RootReducer>) {
		self.window = window
		self.flowController = flowController
		let viewModel = TasksViewModel(flowController: flowController)
		navigationController = GenericNavigationController(rootViewController: TasksController(viewModel: viewModel))
	}
	
	func handle(_ action: RxActionType) -> Observable<RxStateMutator<AppState>> {
		if let state = handleBase(action: action, currentViewController: navigationController) {
			return state
		}
		
		switch action {
		case UIAction.showEditTaskController(let task):
			let viewModel = EditTaskViewModel2(task: task, flowController: flowController)
			navigationController.pushViewController(EditTaskController(viewModel: viewModel), animated: true)
			return .just({ $0 })
		case UIAction.dismisEditTaskController:
			navigationController.popViewController(animated: true)
			return .just({ $0 })
		case UIAction.showSettingsController:
			let controller = GenericNavigationController(rootViewController: SettingsController(viewModel: SettingsViewModel(flowController: flowController)))
			
			let transitionDelegate = TransitionDelegate(presentationController: SlidePresentAnimationController(mode: .toLeft))
			controller.transitioningDelegate = transitionDelegate
			
			let coordinator = SettingsCoordinator(parent: self,
			                                      navigationController: controller, flowController: flowController)
			navigationController.present(coordinator.navigationController, animated: true, completion: nil)
			return .just({ $0.mutation.new(coordinator: coordinator) })
		default: return .empty()
		}
	}
}
