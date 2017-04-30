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
	let controller: UIViewController
	
	init(parent: ApplicationCoordinatorType, controller: UIViewController) {
		self.parent = parent
		self.window = parent.window
		self.controller = controller
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		if let state = handleBase(action: action, flowController: flowController, currentViewController: controller) {
			return state
		}
		
		switch action {
		case UIAction.dismissSettingsController:
			let transitionDelegate = TransitionDelegate(dismissalController: SlideDismissAnimationController(mode: .toLeft))
			controller.transitioningDelegate = transitionDelegate
			
			controller.dismiss(animated: true, completion: nil)
			return .just(flowController.currentState.state.mutation.new(coordinator: parent))
		default: return .just(flowController.currentState.state)
		}
	}
}
