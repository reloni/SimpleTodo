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
	var flowController: RxDataFlowController<AppState> { get }
}

extension ViewModelType {
    private func logOut(flowController: RxDataFlowController<AppState>, error: Error) {
        RxCompositeAction.logOffActions.forEach { flowController.dispatch($0) }
        flowController.dispatch(UIAction.showErrorMessage(error))
    }
    
	func check(error: Error) {
		switch error {
        case AuthenticationError.tokenRevokedError: fallthrough
		case AuthenticationError.notAuthorized: logOut(flowController: flowController, error: error)
		default: flowController.dispatch(UIAction.showSnackView(error: error, hideAfter: 4))
		}
	}
	
	func showWarning(in controller: UIViewController, title: String?, message: String?, actions: [UIAlertAction], sourceView: UIView?) {
		flowController.dispatch(UIAction.showActionSheet(inController: controller, title: title, message: message, actions: actions, sourceView: sourceView))
	}
}
