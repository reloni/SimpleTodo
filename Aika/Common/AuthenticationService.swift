//
//  AuthenticationService.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 06.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
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
	let expiresAt: Date
	let refreshToken: String
	var tokenHeader: String { return "Bearer \(token)" }
	var isTokenExpired: Bool {
		return expiresAt < Date()
	}
}

protocol AuthenticationServiceType {
	func logIn(authType: AuthenticationType) -> Single<AuthenticationInfo>
	func resetPassword(email: String) -> Completable
	func createUser(email: String, password: String) -> Completable
	func refreshToken(info: AuthenticationInfo) -> Single<AuthenticationInfo>
}

struct Auth0AuthenticationService: AuthenticationServiceType {
	func logIn(authType: AuthenticationType) -> Single<AuthenticationInfo> {
		return Auth0AuthenticationService.authenticate(authType: authType)
			.flatMap { tokens -> Single<AuthenticationInfo> in
				return Auth0AuthenticationService.userProfile(token: tokens.accessToken)
					.flatMap { profile -> Single<AuthenticationInfo> in
						return .just(AuthenticationInfo(uid: profile.id,
														token: tokens.idToken,
														expiresAt: tokens.expiresAt ?? Date(),
														refreshToken: tokens.refreshToken))
					}
			}
	}
	
	func createUser(email: String, password: String) -> Completable {
		return Completable.create { completable in
			Auth0
				.authentication()
				.createUser(email: email, username: nil, password: password, connection: "Username-Password-Authentication")
				.start { result in
					switch result {
					case .success: completable(.completed)
					case .failure(error: let error): completable(.error(AuthenticationError.registerError(error)))
					}
			}
			
			return Disposables.create()
		}
	}
	
	func resetPassword(email: String) -> Completable {
		return Completable.create { completable in
			Auth0
				.authentication()
				.resetPassword(email: email, connection: "Username-Password-Authentication")
				.start { result in
					switch result {
					case .success: completable(.completed)
					case .failure(error: let error): completable(.error(AuthenticationError.passwordResetError(error)))
					}
			}
			
			return Disposables.create()
		}
	}
	
	func refreshToken(info: AuthenticationInfo) -> Single<AuthenticationInfo> {
		return Single.create { single in
			Auth0
				.authentication()
				.delegation(withParameters: ["refresh_token": info.refreshToken,
				                             "scope": "openid email",
				                             "api_type": "app"])
				.start { result in
					switch result {
					case .success(let credentials):
						guard let newToken = credentials["id_token"] as? String else { single(.error(AuthenticationError.notAuthorized)); break }
						let jwt = try? decode(jwt: newToken)
                        single(.success(AuthenticationInfo(uid: info.uid,
                                                           token: newToken,
                                                           expiresAt: jwt?.expiresAt ?? Date(),
                                                           refreshToken: info.refreshToken)))
					case .failure(let e as NSError) where e.domain == "com.auth0.authentication" && e.code == 1:
                        single(.error(AuthenticationError.tokenRevokedError(e)))
                    case .failure(let e):
                        single(.error(e))
					}
			}
			
			return Disposables.create()
		}
	}
	
	static func authenticate(authType type: AuthenticationType) -> Single<(idToken: String, refreshToken: String, accessToken: String, expiresAt: Date?)> {
		return Single.create { single in
			let callback: (Auth0.Result<Auth0.Credentials>) -> () = { result in
				switch result {
				case .success(let credentials):
					let jwt = try? decode(jwt: credentials.idToken!)
                    single(SingleEvent.success((idToken: credentials.idToken!,
                                                refreshToken: credentials.refreshToken!,
                                                accessToken: credentials.accessToken!,
                                                expiresAt: jwt?.expiresAt)))
				case .failure(let error):
                    single(SingleEvent.error(AuthenticationError.signInError(error)))
				}
			}
			
			let socialAuth: (String) -> Void = { provider in
				Auth0
					.webAuth()
                    .useLegacyAuthentication()
					.scope("openid profile offline_access")
					.connection(provider)
					.parameters(["device": AppConstants.applicationDeviceInfo])
					.start(callback)
			}
			
			switch type {
			case .db(let email, let password):
				Auth0
					.authentication()
					.login(usernameOrEmail: email,
					       password: password,
					       connection: "Username-Password-Authentication",
					       scope: "openid profile offline_access read:device_credentials",
					       parameters: ["device": AppConstants.applicationDeviceInfo])
					.start(callback)
			case .google: socialAuth("google-oauth2")
			case .facebook: socialAuth("facebook")
			}
			
			return Disposables.create()
		}
	}
	
	static func userProfile(token: String) -> Single<Profile> {
		return Single.create { single in
			
			Auth0
				.authentication()
				.userInfo(token: token)
				.start { result in
					
					switch(result) {
					case .success(let profile):
                        single(.success(profile))
					case .failure(let error):
                        single(.error(error))
					}
			}
			
			return Disposables.create()
		}
	}
}
