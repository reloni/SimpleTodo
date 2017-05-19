//
//  InitialCoordinator.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift
import UIKit

protocol ApplicationCoordinatorType {
	var window: UIWindow { get }
	var flowController: RxDataFlowController<RootReducer> { get }
	func handle(_ action: RxActionType) -> Observable<RxStateMutator<AppState>>
}

extension ApplicationCoordinatorType {
	func handleBase(action: RxActionType, currentViewController controller: UIViewController) -> Observable<RxStateMutator<AppState>>? {
		switch action {
		case UIAction.showErrorMessage(let error):
			showAlert(in: controller, with: error)
			return .just( { $0 })
		case UIAction.showSnackView(let error, let hideAfter):
			showSnackView(with: error, hideAfter: hideAfter)
			return .just({ $0 })
		case UIAction.returnToRootController:
			let model = AuthenticationViewModel(flowController: flowController, mode: .logIn)
			let coordinator = AuthenticationCoordinator(window: window, controller: AuthenticationController(viewModel: model), flowController: flowController)
			set(newRootController: coordinator.controller)
			return .just({ $0.mutation.new(coordinator: coordinator) })
		case UIAction.showSpinner:
			showSpinner()
			return .just({ $0 })
		case UIAction.hideSpinner:
			hideSpinner()
			return .just({ $0 })

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
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		
		actions.forEach { alertController.addAction($0) }
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			alertController.popoverPresentationController?.sourceView = sourceView
			alertController.popoverPresentationController?.sourceRect = sourceView?.bounds ?? .zero
		}
		controller.present(alertController, animated: true, completion: nil)
	}
	
	func set(newRootController controller: UIViewController) {
		transition {
			self.window.rootViewController?.childViewControllers.forEach { $0.dismiss(animated: false, completion: nil) }
			self.window.rootViewController?.dismiss(animated: false, completion: nil)
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
	var flowController: RxDataFlowController<RootReducer> { return flowControllerInitializer() }
	let flowControllerInitializer: () -> RxDataFlowController<RootReducer>
	
	init(window: UIWindow, flowControllerInitializer: @escaping () -> RxDataFlowController<RootReducer>) {
		self.window = window
		self.flowControllerInitializer = flowControllerInitializer
	}
	
	func showLogInController() -> Observable<RxStateMutator<AppState>> {
		let controller = AuthenticationController(viewModel: AuthenticationViewModel(flowController: flowController, mode: .logIn))
		let coordinator = AuthenticationCoordinator(window: window, controller: controller, flowController: flowController)
		set(initialRootController: controller)
		return .just({ $0.mutation.new(coordinator: coordinator) })
	}
	
	func showTasksController() -> Observable<RxStateMutator<AppState>> {
		let coordinator = TasksCoordinator(window: window, flowController: flowController)
	
		set(initialRootController: coordinator.navigationController)
		
		return .just({ $0.mutation.new(coordinator: coordinator) })
	}
	
	func handle(_ action: RxActionType) -> Observable<RxStateMutator<AppState>> {
		switch action {
		case UIAction.showRootController:
			if case Authentication.authenticated = flowController.currentState.state.authentication {
				return showTasksController()
			} else {
				return showLogInController()
			}
		default: fatalError("Only UIAction.showRootController may be dispatched")
		}
	}
}
