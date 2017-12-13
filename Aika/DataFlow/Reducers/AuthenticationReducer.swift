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

func authenticationReducer(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
	switch (action, currentState.authentication) {
	case (AuthenticationAction.logIn(let authType), _): return logIn(currentState: currentState, authType: authType)
	case (AuthenticationAction.register(let email, let password), _): return register(currentState: currentState, email: email, password: password)
	case (AuthenticationAction.logOut, _): return logOut(currentState: currentState)
	case (AuthenticationAction.resetPassword(let email), _): return resetPassword(currentState: currentState, email: email)
	case (AuthenticationAction.refreshToken(let force), _): return refreshToken(currentState: currentState, force: force)
	case (AuthenticationAction.deleteUser, .authenticated): return deleteUser(currentState: currentState)
	default: return .empty()
	}
}
fileprivate func resetPassword(currentState state: AppState, email: String)  -> Observable<RxStateMutator<AppState>> {
	return state.authenticationService.resetPassword(email: email)
		.flatMapLatest { _ -> Observable<RxStateMutator<AppState>> in
			return .just({ $0 })
	}
}

fileprivate func deleteUser(currentState state: AppState) -> Observable<RxStateMutator<AppState>> {
	guard let info = state.authentication.info else { return .empty() }
	
	return state.webService.deleteUser(tokenHeader: info.tokenHeader)
		.flatMap { Observable.just( { $0 } ) }
}

fileprivate func logOut(currentState state: AppState)  -> Observable<RxStateMutator<AppState>> {
	guard let info = state.authentication.info else { return .empty() }
	
	let returnMutator: RxStateMutator<AppState> = { $0.mutation.new(authentication: Authentication.none) }
	
	return state.webService.logOut(refreshToken: info.refreshToken, tokenHeader: info.tokenHeader)
		.do(onDispose: {
			if case let AuthenticationType.db(email, _)? = Keychain.authenticationType {
				Keychain.authenticationType = AuthenticationType.db(email: email, password: "")
			} else {
				Keychain.authenticationType = nil
			}
			Keychain.token = ""
			Keychain.refreshToken = ""
			Keychain.userUuid = ""
			Keychain.tokenExpirationDate = Date()
		})
		.flatMap { Observable<RxStateMutator<AppState>>.just(returnMutator) }
		.catchErrorJustReturn(returnMutator)
}

fileprivate func logIn(currentState state: AppState, authType: AuthenticationType) -> Observable<RxStateMutator<AppState>> {
	return state.authenticationService.logIn(authType: authType)
		.flatMapLatest { result -> Observable<RxStateMutator<AppState>> in
			Keychain.authenticationType = authType
			Keychain.token = result.token
			Keychain.refreshToken = result.refreshToken
			Keychain.tokenExpirationDate = result.expiresAt
			Keychain.userUuid = result.uid
			return .just( { $0.mutation.new(authentication: Authentication.authenticated(result, UserSettings())) } )
	}
}

fileprivate func register(currentState state: AppState, email: String, password: String) -> Observable<RxStateMutator<AppState>> {
	return state.authenticationService.createUser(email: email, password: password)
		.flatMapLatest { _ -> Observable<RxStateMutator<AppState>> in
			return .just( { $0 } )
	}
}

fileprivate func refreshToken(currentState state: AppState, force: Bool) -> Observable<RxStateMutator<AppState>> {
	guard let info = state.authentication.info else { return .empty() }
	
	guard info.isTokenExpired || force else {
		return .just( { $0 })
	}
	
	return state.authenticationService.refreshToken(info: info)
		.flatMapLatest { result -> Observable<RxStateMutator<AppState>> in
			Keychain.token = result.token
			Keychain.refreshToken = result.refreshToken
			Keychain.tokenExpirationDate = result.expiresAt
			return .just( { $0.mutation.new(authentication: .authenticated(result, UserSettings())) } )
		}
		.catchError { error in
			guard !error.isNotConnectedToInternet() && !error.isTimedOut() else { return .just( { $0 } ) }
			return .error(error)
	}
}

