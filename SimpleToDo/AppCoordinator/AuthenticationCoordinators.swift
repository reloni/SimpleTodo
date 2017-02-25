//
//  AuthenticationCoordinators.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 24.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

protocol ApplicationCoordinatorType {
	func handle(_ action: RxActionType, state: AppState) -> Observable<RxStateType>
}

struct RootApplicationCoordinator : ApplicationCoordinatorType {
	let controller: UIViewController
	let window: UIWindow
	
	init(window: UIWindow, controller: UIViewController = SignInController()) {
		self.window = window
		self.controller = controller
	}
	
	func handle(_ action: RxActionType, state: AppState) -> Observable<RxStateType> {
		switch action as? AppAction {
		case .showRootController?:
			window.rootViewController = controller
			window.makeKeyAndVisible()
			return .empty()
		case .showFirebaseRegistration?:
			let coordinator = FirebaseRegistrationCoordinator(parent: self)
			controller.present(coordinator.controller, animated: true, completion: nil)
			return .just(state.new(coordinator: coordinator))
		default: return .empty()
		}
	}
}

struct FirebaseRegistrationCoordinator : ApplicationCoordinatorType {
	let parent: ApplicationCoordinatorType
	let controller: UIViewController
	
	init(parent: ApplicationCoordinatorType, controller: UIViewController = FirebaseRegistrationController()) {
		self.parent = parent
		self.controller = controller
	}
	
	func handle(_ action: RxActionType, state: AppState) -> Observable<RxStateType> {
		switch action as? AppAction {
		case AppAction.dismissFirebaseRegistration?:
			controller.dismiss(animated: true, completion: nil)
			return .just(state.new(coordinator: parent))
		default: return .empty()
		}
	}
}
