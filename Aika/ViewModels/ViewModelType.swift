//
//  ViewModelType.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 13.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import UIKit

protocol ViewModelType {
	var flowController: RxDataFlowController<RootReducer> { get }
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
	
	func showWarning(in controller: UIViewController, title: String?, message: String?, actions: [UIAlertAction], sourceView: UIView?) {
		flowController.dispatch(UIAction.showActionSheet(inController: controller, title: title, message: message, actions: actions, sourceView: sourceView))
	}
}
