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
		switch action as? AuthenticationAction {
		case .logIn(let email, let password)?: return logIn(currentState: currentState, email: email, password: password)
		case .register(let email, let password)?: return register(currentState: currentState, email: email, password: password)
		case .signOut?: return signOut(currentState: currentState)
		case .resetPassword(let email)?: return resetPassword(currentState: currentState, email: email)
		default: return .empty()
		}
	}
}

extension AuthenticationReducer {
	func resetPassword(currentState state: AppState, email: String)  -> Observable<RxStateType> {
		return Observable.create { observer in
			FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
				if let error = error {
					print(error)
					observer.onError(FirebaseError.passwordResetError(error))
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
	
	func signOut(currentState state: AppState)  -> Observable<RxStateType> {
		return Observable.create { observer in
			do {
				try FIRAuth.auth()!.signOut()
			} catch let error {
				observer.onError(error)
			}
			
			Keychain.userPassword = ""
			
			observer.onNext(state)
			observer.onCompleted()
			
			return Disposables.create()
		}
	}
	
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
					observer.onError(FirebaseError.registerError(error))
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

