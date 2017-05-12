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
		case SettingsAction.showLogOffAlert(let sourceView): return showLogOffAlert(flowController: flowController, sourceView: sourceView)
		case SettingsAction.showDeleteCacheAlert(let sourceView): return showDeleteCacheAlert(flowController: flowController, sourceView: sourceView)
		case UIAction.dismissSettingsController:
			let transitionDelegate = TransitionDelegate(dismissalController: SlideDismissAnimationController(mode: .toLeft))
			navigationController.transitioningDelegate = transitionDelegate
			
			navigationController.dismiss(animated: true, completion: nil)
			return .just(flowController.currentState.state.mutation.new(coordinator: parent))
		default: return .just(flowController.currentState.state)
		}
	}
	
	func showLogOffAlert(flowController: RxDataFlowController<AppState>, sourceView: UIView) -> Observable<RxStateType> {
		guard let settingsController = navigationController.topViewController as? SettingsController else {
			return .just(flowController.currentState.state)
		}
		
		let logOffHandler: ((UIAlertAction) -> Void)? = { _ in settingsController.viewModel.logOff() }
		let actions = [UIAlertAction(title: "Log off", style: .destructive, handler: logOffHandler),
		               UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
		
		showActionSheet(in: settingsController, withTitle: nil, message: nil, actions: actions, sourceView: sourceView)
		
		return .just(flowController.currentState.state)
	}
	
	func showDeleteCacheAlert(flowController: RxDataFlowController<AppState>, sourceView: UIView) -> Observable<RxStateType> {
		guard let settingsController = navigationController.topViewController as? SettingsController else {
			return .just(flowController.currentState.state)
		}
		
		let deleteHandler: ((UIAlertAction) -> Void)? = { _ in settingsController.viewModel.deleteCache() }
		let actions = [UIAlertAction(title: "Delete cache", style: .destructive, handler: deleteHandler),
		               UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
		
		showActionSheet(in: settingsController, withTitle: "Warning", message: "Not synchronized data will be lost", actions: actions, sourceView: sourceView)
		
		return .just(flowController.currentState.state)
	}
}
