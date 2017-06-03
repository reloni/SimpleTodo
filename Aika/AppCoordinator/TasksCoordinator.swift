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
			let viewModel = EditTaskViewModel(task: task, flowController: flowController)
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
		case TasksAction.showDeleteTaskAlert(let sourceView, let taskUuid): return showDeleteTaskAlert(sourceView: sourceView, taskUuid: taskUuid)
		default: return .empty()
		}
	}
	
	func showDeleteTaskAlert(sourceView: UIView, taskUuid: UniqueIdentifier) -> Observable<RxStateMutator<AppState>> {
		guard let controller = navigationController.topViewController as? TasksController else {
			return .just({ $0 })
		}
		
		let deleteHandler: ((UIAlertAction) -> Void)? = { _ in controller.viewModel.deleteTask(forUuid: taskUuid) }
		let actions = [UIAlertAction(title: "Delete task", style: .destructive, handler: deleteHandler),
		               UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
		
		showActionSheet(in: controller, withTitle: nil, message: nil, actions: actions, sourceView: sourceView)
		
		return .just({ $0 })
	}
}
