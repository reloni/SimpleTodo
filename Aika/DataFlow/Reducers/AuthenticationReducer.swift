//
//  AuthenticationReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 12.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow
import Auth0

struct AuthenticationReducer : RxReducerType {	
	func handle(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
		switch action as? AuthenticationAction {
		case .logIn(let authType)?: return logIn(currentState: currentState, authType: authType)
		case .register(let email, let password)?: return register(currentState: currentState, email: email, password: password)
		case .signOut?: return signOut()
		case .resetPassword(let email)?: return resetPassword(currentState: currentState, email: email)
		case .refreshToken(let force)?: return refreshToken(currentState: currentState, force: force)
		default: return .empty()
		}
	}
}

extension AuthenticationReducer {
	func resetPassword(currentState state: AppState, email: String)  -> Observable<RxStateMutator<AppState>> {
		return state.authenticationService.resetPassword(email: email)
			.flatMapLatest { _ -> Observable<RxStateMutator<AppState>> in
				return .just({ $0 })
			}
	}
	
	func signOut()  -> Observable<RxStateMutator<AppState>> {
		Keychain.userPassword = ""
		Keychain.token = ""
		Keychain.refreshToken = ""
		Keychain.userUuid = ""
		
		return .just( { $0.mutation.new(authentication: Authentication.none) })
	}
	
	func logIn(currentState state: AppState, authType: AuthenticationType) -> Observable<RxStateMutator<AppState>> {
		return state.authenticationService.logIn(authType: authType)
			.flatMapLatest { result -> Observable<RxStateMutator<AppState>> in
				if case .db(let data) = authType {
					Keychain.userEmail = data.email
					Keychain.userPassword = data.password
				}
				Keychain.token = result.token
				Keychain.refreshToken = result.refreshToken
				Keychain.userUuid = result.uid
				return .just( { $0.mutation.new(authentication: Authentication.authenticated(result, UserSettings())) } )
			}
	}
	
	func register(currentState state: AppState, email: String, password: String) -> Observable<RxStateMutator<AppState>> {
		return state.authenticationService.createUser(email: email, password: password)
			.flatMapLatest { _ -> Observable<RxStateMutator<AppState>> in
				return .just( { $0 } )
		}
	}
	
	func refreshToken(currentState state: AppState, force: Bool) -> Observable<RxStateMutator<AppState>> {
		guard let info = state.authentication.info else { return .empty() }
		
		guard info.isTokenExpired || force else {
			return .just( { $0 })
		}
		
		return state.authenticationService.refreshToken(info: info)
			.flatMapLatest { result -> Observable<RxStateMutator<AppState>> in
				return .just( { $0.mutation.new(authentication: .authenticated(result, UserSettings())) } )
			}
			.catchError { error in
				guard !error.isNotConnectedToInternet() && !error.isTimedOut() else { return .just( { $0 } ) }
				return .error(error)
		}
	}
}

