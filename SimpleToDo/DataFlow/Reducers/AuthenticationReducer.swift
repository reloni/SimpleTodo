//
//  AuthenticationReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 12.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow

struct AuthenticationReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		let currentState = flowController.currentState.state
		switch action as? SignInAction {
		case .dismissFirebaseRegistration?: fallthrough
		case .showTasksListController?: fallthrough
		case .showFirebaseRegistration?: return currentState.coordinator.handle(action, flowController: flowController)
		case .logIn(let email, let password)?: return logIn(currentState: currentState, email: email, password: password)
		case .register(let email, let password)?: return register(currentState: currentState, email: email, password: password)
		default: return .empty()
		}
	}
}

extension AuthenticationReducer {
	func logIn(currentState state: AppState, email: String, password: String) -> Observable<RxStateType> {
		return Observable.create { observer in
			FIRAuth.auth()!.signIn(withEmail: email, password: password) { user, error in
				if let error = error {
					observer.onError(FirebaseError.signInError(error))
					return
				}
				
				Keychain.userEmail = email
				Keychain.userPassword = password
				
				observer.onNext(state.mutation.new(authentication: Authentication.user(user!)))
				observer.onCompleted()
			}
			
			return Disposables.create {
				observer.onCompleted()
			}
		}
	}
	
	func register(currentState state: AppState, email: String, password: String) -> Observable<RxStateType> {
		return Observable.create { observer in
			FIRAuth.auth()!.createUser(withEmail: email, password: password) { user, error in
				if let error = error {
					observer.onError(FirebaseError.signInError(error))
					return
				}
				
				observer.onNext(state)
				observer.onCompleted()
			}
			
			return Disposables.create {
				observer.onCompleted()
			}
		}
	}
}

