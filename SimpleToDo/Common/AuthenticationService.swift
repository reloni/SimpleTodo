//
//  AuthenticationService.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 06.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Auth0
import JWTDecode
import RxSwift
import RxHttpClient

protocol LoginUser {
	var uid: String { get }
	var token: Observable<String> { get }
}

extension LoginUser {
	var tokenHeader: Observable<String> {
		return token.flatMap { token -> Observable<String> in return .just("Bearer \(token)") }
	}
}

struct AuthenticationInfo {
	let uid: String
	let token: String
	let expiresAt: Date?
	let refreshToken: String
	var tokenHeader: String { return "Bearer \(token)" }
	var isTokenExpired: Bool {
		guard let expiresAt = expiresAt else { return true }
		return expiresAt < Date()
	}
}

protocol AuthenticationServiceType {
	func logIn(userNameOrEmail: String, password: String) -> Observable<AuthenticationInfo>
	func resetPassword(email: String) -> Observable<Void>
	func createUser(email: String, password: String) -> Observable<Void>
	func refreshToken(info: AuthenticationInfo) -> Observable<AuthenticationInfo>
}

struct Auth0AuthenticationService: AuthenticationServiceType {
	func logIn(userNameOrEmail: String, password: String) -> Observable<AuthenticationInfo> {
		return Auth0AuthenticationService.authenticate(userNameOremail: userNameOrEmail, password: password)
			.flatMapLatest { tokens -> Observable<AuthenticationInfo> in
				return Auth0AuthenticationService.userProfile(token: tokens.accessToken)
					.flatMapLatest { profile -> Observable<AuthenticationInfo> in
						return .just(AuthenticationInfo(uid: profile.id, token: tokens.idToken, expiresAt: tokens.expiresAt, refreshToken: tokens.refreshToken))
					}
			}
	}
	
	func createUser(email: String, password: String) -> Observable<Void> {
		return Observable.create { observer in
			Auth0
				.authentication()
				.createUser(email: email, username: nil, password: password, connection: "Username-Password-Authentication")
				.start { result in
					switch result {
					case .success: observer.onCompleted()
					case .failure(error: let error): observer.onError(AuthenticationError.registerError(error))
					}
			}
			
			return Disposables.create {
				observer.onCompleted()
			}
		}
	}
	
	func resetPassword(email: String) -> Observable<Void> {
		return Observable.create { observer in
			Auth0
				.authentication()
				.resetPassword(email: email, connection: "Username-Password-Authentication")
				.start { result in
					switch result {
					case .success: observer.onCompleted()
					case .failure(error: let error): observer.onError(AuthenticationError.passwordResetError(error))
					}
			}
			
			return Disposables.create {
				observer.onCompleted()
			}
		}
	}
	
	func refreshToken(info: AuthenticationInfo) -> Observable<AuthenticationInfo> {
		return Observable.create { observer in
			Auth0
				.authentication()
				.delegation(withParameters: ["refresh_token": info.refreshToken,
				                             "scope": "openid email",
				                             "api_type": "app"])
				.start { result in
					switch result {
					case .success(let credentials):
						guard let newToken = credentials["id_token"] as? String else { observer.onError(AuthenticationError.notAuthorized); break }
						let jwt = try? decode(jwt: newToken)
						observer.onNext(AuthenticationInfo(uid: info.uid, token: newToken, expiresAt: jwt?.expiresAt, refreshToken: info.refreshToken))
						observer.onCompleted()
					case .failure(let error):
						if error.isNotConnectedToInternet() {
							observer.onError(HttpClientError.clientSideError(error: error))
						} else {
							observer.onError(AuthenticationError.notAuthorized)
						}
					}
			}
			
			return Disposables.create {
				observer.onCompleted()
			}
		}
	}
	
	static func authenticate(userNameOremail: String, password: String) -> Observable<(idToken: String, refreshToken: String, accessToken: String, expiresAt: Date?)> {
		return Observable.create { observer in
			Auth0
				.authentication()
				.login(usernameOrEmail: userNameOremail,
				       password: password,
				       connection: "Username-Password-Authentication",
				       scope: "openid profile offline_access read:device_credentials",
				       parameters: ["device": Keychain.deviceUuid])
				.start { result in
					
					switch result {
					case .success(let credentials):
						
						let jwt = try? decode(jwt: credentials.idToken!)
						observer.onNext((idToken: credentials.idToken!, refreshToken: credentials.refreshToken!, accessToken: credentials.accessToken!, expiresAt: jwt?.expiresAt))
						observer.onCompleted()
					case .failure(let error):
						observer.onError(AuthenticationError.signInError(error))
					}
			}
			
			return Disposables.create {
				observer.onCompleted()
			}
		}
	}

	
	static func userProfile(token: String) -> Observable<Profile> {
		return Observable.create { observer in
			
			Auth0
				.authentication()
				.userInfo(token: token)
				.start { result in
					
					switch(result) {
					case .success(let profile):
						observer.onNext(profile)
						observer.onCompleted()
					case .failure(let error):
						observer.onError(error)
					}
			}
			
			return Disposables.create {
				observer.onCompleted()
			}
		}
	}
}
