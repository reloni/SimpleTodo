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
		case UIAction.showErrorMessage(let error):
			showAlert(in: controller, with: error)
			return .just(flowController.currentState.state)
		case UIAction.showSnackView(let error, let hideAfter):
			showSnackView(with: error, hideAfter: hideAfter)
			return .just(flowController.currentState.state)
		case UIAction.returnToRootController:
			let coordinator = AuthenticationCoordinator(window: window, controller: AuthenticationController(viewModel: AuthenticationViewModel(flowController: flowController,
			                                                                                                                                    mode: .logIn)))
			set(newRootController: coordinator.controller)
			return .just(flowController.currentState.state.mutation.new(coordinator: coordinator))
		case UIAction.showSpinner:
			showSpinner()
			return .just(flowController.currentState.state)
		case UIAction.hideSpinner:
			hideSpinner()
			return .just(flowController.currentState.state)
		default: return nil
		}
	}
	
	func showSnackView(with error: Error, hideAfter: Double?) {
		guard let message = error.uiAlertMessage() else { return }
		SnackView.show(snackView: MessageSnackView(message: message), in: window)
		
		guard let hideAfter = hideAfter else { return }
		DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(Int(hideAfter * 1000))) { SnackView.remove(from: self.window)  }
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
	
	func showSpinner() {
		ActivityView.show(in: window)
	}
	
	func hideSpinner() {
		ActivityView.remove(from: window)
	}
	
	func show(snackView: SnackView) {
		SnackView.show(snackView: snackView, in: window)
	}
	
	func removeSnackView(from window: UIWindow) {
		SnackView.remove(from: window)
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
