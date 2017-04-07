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
	var window: UIWindow { get }
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType>
}

extension ApplicationCoordinatorType {
	func showAlert(in controller: UIViewController, with error: Error) {
		guard let message = error.uiAlertMessage() else { return }
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		controller.present(alert, animated: true, completion: nil)
	}
	
	func set(newRootController controller: UIViewController) {
		transition {
			self.window.rootViewController = controller
		}
	}
	
	func set(initialRootController controller: UIViewController) {
		transition {
			self.window.rootViewController = controller
			self.window.makeKeyAndVisible()
		}
	}
	
	func transition(withDuration duration: TimeInterval = 0.6,
	                options: UIViewAnimationOptions = [UIViewAnimationOptions.transitionCrossDissolve], animations: @escaping (() -> Void)) {
		UIView.transition(with: window,
		                  duration: duration,
		                  options: options,
		                  animations: animations,
		                  completion: nil)
	}
}

struct SignInCoordinator : ApplicationCoordinatorType {
	let controller: UIViewController?
	let window: UIWindow
	
	init(window: UIWindow, controller: UIViewController? = nil) {
		self.window = window
		self.controller = controller
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		switch action {
		case GeneralAction.showRootController:
			set(initialRootController: SignInController(viewModel: SignInViewModel(flowController: flowController)))
			return .just(flowController.currentState.state.mutation.new(coordinator: SignInCoordinator.init(window: window, controller: window.rootViewController)))
		case SignInAction.showFirebaseRegistration:
			let coordinator = FirebaseRegistrationCoordinator(parent: self)
			controller!.present(coordinator.controller, animated: true, completion: nil)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		case GeneralAction.error(let error):
			showAlert(in: controller!, with: error)
			return .just(flowController.currentState.state)
		case SignInAction.showTasksListController:
			let coordinator = TasksCoordinator(window: window, flowController: flowController)
			set(newRootController: coordinator.navigationController)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		default: return .empty()
		}
	}
}

struct FirebaseRegistrationCoordinator : ApplicationCoordinatorType {
	let parent: ApplicationCoordinatorType
	let window: UIWindow
	let controller: UIViewController
	
	init(parent: ApplicationCoordinatorType, controller: UIViewController = FirebaseRegistrationController()) {
		self.parent = parent
		self.window = parent.window
		self.controller = controller
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		switch action {
		case SignInAction.dismissFirebaseRegistration:
			controller.dismiss(animated: true, completion: nil)
			return .just(flowController.currentState.state.mutation.new(coordinator: parent))
		case GeneralAction.error(let error):
			showAlert(in: controller, with: error)
			return .just(flowController.currentState.state)
		default: return .empty()
		}
	}
}
