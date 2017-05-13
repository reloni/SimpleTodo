//
//  ViewModelType.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 13.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow

protocol ViewModelType {
	var flowController: RxDataFlowController<AppState> { get }
}

extension ViewModelType {
	func check(error: Error) {
		if case AuthenticationError.notAuthorized = error {
			RxCompositeAction.logOffActions.forEach { flowController.dispatch($0) }
			flowController.dispatch(UIAction.showErrorMessage(error))
		} else {
			flowController.dispatch(UIAction.showSnackView(error: error, hideAfter: 4))
		}
	}
}
