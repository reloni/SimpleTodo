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
		case .refreshToken(let force)?: return refreshToken(currentState: currentState, force: force)
		default: return .empty()
		}
	}
}

extension AuthenticationReducer {
	func resetPassword(currentState state: AppState, email: String)  -> Observable<RxStateType> {
		return state.authenticationService.resetPassword(email: email)
			.flatMapLatest { _ -> Observable<RxStateType> in
					return .just(state)
			}
	}
	
	func signOut(currentState state: AppState)  -> Observable<RxStateType> {
		return Observable.create { observer in
			Keychain.userPassword = ""
			Keychain.token = ""
			Keychain.refreshToken = ""
			Keychain.userUuid = ""
			
			observer.onNext(state)
			observer.onCompleted()
			
			return Disposables.create()
		}
	}
	
	func logIn(currentState state: AppState, email: String, password: String) -> Observable<RxStateType> {
		return state.authenticationService.logIn(userNameOrEmail: email, password: password)
			.flatMapLatest { result -> Observable<RxStateType> in
				Keychain.userEmail = email
				Keychain.userPassword = password
				Keychain.token = result.token
				Keychain.refreshToken = result.refreshToken
				Keychain.userUuid = result.uid
				return .just(state.mutation.new(authentication: Authentication.authenticated(result, UserSettings())))
			}
	}
	
	func register(currentState state: AppState, email: String, password: String) -> Observable<RxStateType> {
		return state.authenticationService.createUser(email: email, password: password)
			.flatMapLatest { _ -> Observable<RxStateType> in
				return .just(state)
		}
	}
	
	func refreshToken(currentState state: AppState, force: Bool) -> Observable<RxStateType> {
		guard let info = state.authentication.info else { return .error(AuthenticationError.notAuthorized) }
		
		guard info.isTokenExpired || force else {
			return .just(state)
		}
		
		return state.authenticationService.refreshToken(info: info)
			.flatMapLatest { result -> Observable<RxStateType> in
				return .just(state.mutation.new(authentication: .authenticated(result, UserSettings())))
			}
	}
}

