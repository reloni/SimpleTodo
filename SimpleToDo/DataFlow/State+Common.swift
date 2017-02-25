//
//  State+Common.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 25.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

extension AppLogic {
	var common: StateCommon { return StateCommon(state: state) }
}

struct StateCommon {
	let state: AppState

	func showAlert(in controller: UIViewController, with error: Error) -> Observable<RxStateType> {
		guard let message = error.uiAlertMessage() else { return .empty() }
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		controller.present(alert, animated: true, completion: nil)
		return .just(state)
	}
}
