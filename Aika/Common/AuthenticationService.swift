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

enum AuthenticationType {
	case db(email: String, password: String)
	case google
	case facebook
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
	func logIn(authType: AuthenticationType) -> Observable<AuthenticationInfo>
	func resetPassword(email: String) -> Observable<Void>
	func createUser(email: String, password: String) -> Observable<Void>
	func refreshToken(info: AuthenticationInfo) -> Observable<AuthenticationInfo>
}

struct Auth0AuthenticationService: AuthenticationServiceType {
	func logIn(authType: AuthenticationType) -> Observable<AuthenticationInfo> {
		return Auth0AuthenticationService.authenticate(authType: authType)
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
					case .failure(let e as NSError) where e.domain == "com.auth0.authentication" && e.code == 1:
                        observer.onError(AuthenticationError.tokenRevokedError(e))
                    case .failure(let e):
                        observer.onError(e)
					}
			}
			
			return Disposables.create {
				observer.onCompleted()
			}
		}
	}
	
	static func authenticate(authType type: AuthenticationType) -> Observable<(idToken: String, refreshToken: String, accessToken: String, expiresAt: Date?)> {
		return Observable.create { observer in
			
			let callback: (Auth0.Result<Auth0.Credentials>) -> () = { result in
				switch result {
				case .success(let credentials):
					let jwt = try? decode(jwt: credentials.idToken!)
					observer.onNext((idToken: credentials.idToken!,
					                 refreshToken: credentials.refreshToken!, 
					                 accessToken: credentials.accessToken!, 
					                 expiresAt: jwt?.expiresAt))
					observer.onCompleted()
				case .failure(let error):
					observer.onError(AuthenticationError.signInError(error))
				}
			}
			
			switch type {
			case .db(let email, let password):
				Auth0
					.authentication()
					.login(usernameOrEmail: email,
					       password: password,
					       connection: "Username-Password-Authentication",
					       scope: "openid profile offline_access read:device_credentials",
					       parameters: ["device": Keychain.deviceUuid])
					.start(callback)
			case .google:
				Auth0
					.webAuth()
					.scope("openid profile offline_access")
					.connection("google-oauth2")
					.start(callback)
			case .facebook:
				Auth0
					.webAuth()
					.scope("openid profile offline_access")
					.connection("facebook")
					.start(callback)
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
