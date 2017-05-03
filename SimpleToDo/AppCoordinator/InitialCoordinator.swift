//
//  InitialCoordinator.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

protocol ApplicationCoordinatorType {
	var window: UIWindow { get }
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType>
}

extension ApplicationCoordinatorType {
	func handleBase(action: RxActionType, flowController: RxDataFlowController<AppState>, currentViewController controller: UIViewController) -> Observable<RxStateType>? {
		switch action {
		case UIAction.showError(let error):
			showAlert(in: controller, with: error)
			return .just(flowController.currentState.state)
		case UIAction.returnToRootController:
			let coordinator = AuthenticationCoordinator(window: window, controller: AuthenticationController(viewModel: AuthenticationViewModel(flowController: flowController,
			                                                                                                                                    mode: .logIn)))
			set(newRootController: coordinator.controller)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		default: return nil
		}
	}
	
	func showAlert(in controller: UIViewController, with error: Error) {
		guard let message = error.uiAlertMessage() else { return }
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		controller.present(alert, animated: true, completion: nil)
	}
	
	func showActionSheet(in controller: UIViewController, withTitle title: String?, message: String?, actions: [UIAlertAction], sourceView: UIView?) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		actions.forEach { alertController.addAction($0) }
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			alertController.popoverPresentationController?.sourceView = sourceView
			alertController.popoverPresentationController?.sourceRect = sourceView?.bounds ?? .zero
		}
		controller.present(alertController, animated: true, completion: nil)
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
	
	func transition(withDuration duration: TimeInterval = 0.5,
	                options: UIViewAnimationOptions = [UIViewAnimationOptions.transitionCrossDissolve], animations: @escaping (() -> Void)) {
		UIView.transition(with: window,
		                  duration: duration,
		                  options: options,
		                  animations: animations,
		                  completion: nil)
	}
}

struct InitialCoordinator : ApplicationCoordinatorType {
	let window: UIWindow
	
	init(window: UIWindow) {
		self.window = window
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		switch action {
		case UIAction.showRootController:
			let controller = AuthenticationController(viewModel: AuthenticationViewModel(flowController: flowController, mode: .logIn))
			let coordinator = AuthenticationCoordinator(window: window, controller: controller)
			set(initialRootController: controller)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		default: fatalError("Only UIAction.showRootController may be dispatched")
		}
	}
}
