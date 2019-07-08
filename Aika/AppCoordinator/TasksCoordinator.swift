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
	let flowController: RxDataFlowController<AppState>
	
	init(window: UIWindow, flowController: RxDataFlowController<AppState>) {
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
			let viewModel = EditTaskViewModel(task: task, flowController: flowController)
			navigationController.pushViewController(EditTaskController(viewModel: viewModel), animated: true)
			return .just({ $0 })
		case UIAction.dismisEditTaskController:
			navigationController.popViewController(animated: true)
			return .just({ $0 })
		case UIAction.showSettingsController:
			let controller = GenericNavigationController(rootViewController: SettingsController(viewModel: SettingsViewModel(flowController: flowController)))
			
			let coordinator = SettingsCoordinator(parent: self,
			                                      navigationController: controller, flowController: flowController)
			navigationController.present(coordinator.navigationController, animated: true, completion: nil)
			return .just({ $0.mutation.new(coordinator: coordinator) })
		case UIAction.showTaskRepeatModeController(let currentPattern):
			let viewModel = TaskRepeatModeViewModel(flowController: flowController, currentPattern: currentPattern)
			navigationController.pushViewController(TaskRepeatModeController(viewModel: viewModel), animated: true)
			return .just({ $0 })
		case UIAction.showTaskCustomRepeatModeController(let currentMode):
            let viewModel = CustomTaskRepeatModeViewModel(flowController: flowController, currentMode: currentMode, calendar: Calendar.current)
			navigationController.pushViewController(CustomTaskRepeatModeController(viewModel: viewModel), animated: true)
			return .just({ $0 })
		case UIAction.dismissTaskRepeatModeController:
			navigationController.popViewController(animated: true)
			return .just({ $0 })
		default: return .empty()
		}
	}
}
