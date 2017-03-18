//
//  SignInViewModel.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 25.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift
import RxDataFlow

final class SignInViewModel {
	let flowController: RxDataFlowController<AppState>
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in
			guard let object = self else { return }
			object.flowController.dispatch(GeneralAction.error($0.error))
		})
	}()
	
	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
	}
	
	var email: String {
		return Keychain.userEmail
	}
	
	var password: String {
		return Keychain.userPassword
	}
	
	func logIn(email: String, password: String) {
		flowController.dispatch(RxCompositeAction(actions: [SignInAction.logIn(email, password),
		                                                    SignInAction.showTasksListController]))
	}
}
