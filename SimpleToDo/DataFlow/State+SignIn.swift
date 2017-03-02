//
//  State+SignIn.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 25.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

extension SignInReducer {
	func logIn(currentState state: AppState, email: String, password: String) -> Observable<RxStateType> {
		return Observable.create { observer in
			FIRAuth.auth()!.signIn(withEmail: email, password: password) { user, error in
				if let error = error {
					observer.onError(FirebaseError.signInError(error))
					return
				}
				
				observer.onNext(state.mutation.new(logInInfo: LogInInfo(email: "", password: "", firebaseUser: user!)))
				observer.onCompleted()
			}
			
			return Disposables.create {
				observer.onCompleted()
			}
		}
	}
}
