//
//  UIActions.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 02.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RxDataFlow
import RxSwift
import UIKit
import RxHttpClient

struct UICoordinator {
	static func dismisEditEntryController(currentState state: AppState) -> Observable<RxStateType> {
			state.rootController.popViewController(animated: true)
			return .just(state)
	}
	
	static func showAlert(in controller: UIViewController, with error: Error, currentState state: AppState) -> Observable<RxStateType> {
		guard let message = error.uiAlertMessage() else { return .empty() }
		let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		controller.present(alert, animated: true, completion: nil)
		return .just(state)
	}
	
	static func showEditEntryController(forTask task: Task?, currentState state: AppState) -> Observable<RxStateType> {
		state.rootController.pushViewController(EditTaskController(task: task), animated: true)
		return .just(state)
	}
}
