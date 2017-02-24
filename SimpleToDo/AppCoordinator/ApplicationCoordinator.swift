//
//  ApplicationCoordinator.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 24.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

protocol ApplicationCoordinatorType {
	func handle(_ action: RxActionType) -> Observable<RxStateType>
}

struct RootApplicationCoordinator : ApplicationCoordinatorType {
	let controller: UIViewController
	let window: UIWindow
	
	init(window: UIWindow, controller: UIViewController = SignInController()) {
		self.window = window
		self.controller = controller
	}
	
	func handle(_ action: RxActionType) -> Observable<RxStateType> {
		switch action as? AppAction {
		case .showRootController?:
			//applicationStore.currentState.state.rootController.viewControllers.append(SignInController())
			window.rootViewController = controller
			window.makeKeyAndVisible()
		default: break
		}
		return .empty()
	}
}
