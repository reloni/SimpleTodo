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
	let flowController: RxDataFlowController<RootReducer>
	
	init(parent: ApplicationCoordinatorType, navigationController: GenericNavigationController, flowController: RxDataFlowController<RootReducer>) {
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
		case SettingsAction.showLogOffAlert(let sourceView): return showLogOffAlert(sourceView: sourceView)
		case SettingsAction.showDeleteCacheAlert(let sourceView): return showDeleteCacheAlert(sourceView: sourceView)
		case UIAction.dismissSettingsController:
			let transitionDelegate = TransitionDelegate(dismissalController: SlideDismissAnimationController(mode: .toRight))
			navigationController.transitioningDelegate = transitionDelegate
			
			navigationController.dismiss(animated: true, completion: nil)

			let parentCoordinator = parent
			return .just({ $0.mutation.new(coordinator: parentCoordinator) })
		default: return .just({ $0 })
		}
	}
	
	func showLogOffAlert(sourceView: UIView) -> Observable<RxStateMutator<AppState>> {
		guard let settingsController = navigationController.topViewController as? SettingsController else {
			return .just({ $0 })
		}
		
		let logOffHandler: ((UIAlertAction) -> Void)? = { _ in settingsController.viewModel.logOff() }
		let actions = [UIAlertAction(title: "Log off", style: .destructive, handler: logOffHandler),
		               UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
		
		showActionSheet(in: settingsController, withTitle: nil, message: nil, actions: actions, sourceView: sourceView)
		
		return .just({ $0 })
	}
	
	func showDeleteCacheAlert(sourceView: UIView) -> Observable<RxStateMutator<AppState>> {
		guard let settingsController = navigationController.topViewController as? SettingsController else {
			return .just({ $0 })
		}
		
		let deleteHandler: ((UIAlertAction) -> Void)? = { _ in settingsController.viewModel.deleteCache() }
		let actions = [UIAlertAction(title: "Delete cache", style: .destructive, handler: deleteHandler),
		               UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
		
		showActionSheet(in: settingsController, withTitle: "Warning", message: "Not synchronized data will be lost", actions: actions, sourceView: sourceView)
		
		return .just({ $0 })
	}
}
