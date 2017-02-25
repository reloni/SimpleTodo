//
//  SignInLogic.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 25.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RxDataFlow
import RxSwift

extension AppState {
	func signIn(email: String, password: String) -> Observable<RxStateType> {
		return Observable.create { observer in
			FIRAuth.auth()!.signIn(withEmail: email, password: password) { user, error in
				if let error = error {
					observer.onError(FirebaseError.signInError(error))
					return
				}
				
				observer.onNext(self.new(logInInfo: LogInInfo(email: "", password: "", firebaseUser: user!)))
				observer.onCompleted()
			}
			
			return Disposables.create {
				observer.onCompleted()
			}
		}
	}
}
