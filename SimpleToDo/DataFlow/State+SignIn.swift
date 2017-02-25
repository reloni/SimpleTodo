//
//  State+SignIn.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 25.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

extension AppLogic {
	var signIn: StateSignIn { return StateSignIn(state: state) }
}

struct StateSignIn {
	let state: AppState
	
	func logIn(email: String, password: String) -> Observable<RxStateType> {
		return Observable.create { observer in
			FIRAuth.auth()!.signIn(withEmail: email, password: password) { user, error in
				if let error = error {
					observer.onError(FirebaseError.signInError(error))
					return
				}
				
				observer.onNext(self.state.mutation.new(logInInfo: LogInInfo(email: "", password: "", firebaseUser: user!)))
				observer.onCompleted()
			}
			
			return Disposables.create {
				observer.onCompleted()
			}
		}
	}
}
