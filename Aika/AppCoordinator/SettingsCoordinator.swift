//
//  SettingsCoordinator.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow
import UIKit

struct SettingsCoordinator : ApplicationCoordinatorType {
	let parent: ApplicationCoordinatorType
	let window: UIWindow
	let navigationController: GenericNavigationController
	let flowController: RxDataFlowController<AppState>
	
	init(parent: ApplicationCoordinatorType, navigationController: GenericNavigationController, flowController: RxDataFlowController<AppState>) {
		self.parent = parent
		self.window = parent.window
		self.navigationController = navigationController
		self.flowController = flowController
	}
	
	func handle(_ action: RxActionType) -> Observable<RxStateMutator<AppState>> {
		if let state = handleBase(action: action, currentViewController: navigationController) {
			return state
		}
		
		switch action {
		case UIAction.dismissSettingsController: return dismissSettingsController()
		case SettingsAction.showFrameworksController: return showFrameworksController()
		default: return .just({ $0 })
		}
	}
	
	func showFrameworksController() -> Observable<RxStateMutator<AppState>> {
		let viewModel = FrameworksViewModel(flowController: flowController)
		let controller = FrameworksController(viewModel: viewModel)
		navigationController.pushViewController(controller, animated: true)
		return .just { $0 }
	}
	
	func dismissSettingsController() -> Observable<RxStateMutator<AppState>> {
		let transitionDelegate = TransitionDelegate(dismissalController: SlideDismissAnimationController(mode: .toRight))
		navigationController.transitioningDelegate = transitionDelegate
		
		navigationController.dismiss(animated: true, completion: nil)
		
		let parentCoordinator = parent
		return .just({ $0.mutation.new(coordinator: parentCoordinator) })
	}
}
