//
//  SettingsCoordinator.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow

struct SettingsCoordinator : ApplicationCoordinatorType {
	let parent: ApplicationCoordinatorType
	let window: UIWindow
	let navigationController: GenericNavigationController
	
	init(parent: ApplicationCoordinatorType, navigationController: GenericNavigationController) {
		self.parent = parent
		self.window = parent.window
		self.navigationController = navigationController
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		if let state = handleBase(action: action, flowController: flowController, currentViewController: navigationController) {
			return state
		}
		
		switch action {
		case SettingsAction.showLogOffAlert(let sourceView):
			guard let settingsController = navigationController.topViewController as? SettingsController else {
				return .just(flowController.currentState.state)
			}
			
			let logOffHandler: ((UIAlertAction) -> Void)? = { _ in settingsController.viewModel.logOff() }
			let actions = [UIAlertAction(title: "Log off", style: .destructive, handler: logOffHandler),
			               UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
			
			showActionSheet(in: settingsController, withTitle: "", message: "", actions: actions, sourceView: sourceView)
			
			return .just(flowController.currentState.state)
		case UIAction.dismissSettingsController:
			let transitionDelegate = TransitionDelegate(dismissalController: SlideDismissAnimationController(mode: .toLeft))
			navigationController.transitioningDelegate = transitionDelegate
			
			navigationController.dismiss(animated: true, completion: nil)
			return .just(flowController.currentState.state.mutation.new(coordinator: parent))
		default: return .just(flowController.currentState.state)
		}
	}
}
