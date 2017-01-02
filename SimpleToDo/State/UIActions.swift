//
//  UIActions.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 02.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RxState
import RxSwift
import UIKit
import RxHttpClient

func dismisEditEntryControllerActionWork() -> RxActionWork {
	return RxActionWork(scheduler: MainScheduler.instance) { state -> RxActionResultType in
		let state = state as! AppState
		state.rootController.popViewController(animated: true)
		return RxDefaultActionResult()
	}
}

func showAlertActionWork(in controller: UIViewController, with error: Error) -> RxActionWork {
	return RxActionWork(scheduler: MainScheduler.instance) { state -> RxActionResultType in
		guard let message = error.uiAlertMessage() else { return RxDefaultActionResult() }
		let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		controller.present(alert, animated: true, completion: nil)
		return RxDefaultActionResult()
	}
}

func showEditEntryControllerActionWork(_ entry: ToDoEntry?) -> RxActionWork {
	return RxActionWork(scheduler: MainScheduler.instance) { state -> RxActionResultType in
		let state = state as! AppState
		state.rootController.pushViewController(EditToDoEntryController(entry: entry), animated: true)
		return RxDefaultActionResult()
	}
}
