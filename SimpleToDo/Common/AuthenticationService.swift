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
	func logIn(userNameOremail: String, password: String) -> Observable<AuthenticationInfo>
}

struct Auth0AuthenticationService: AuthenticationServiceType {
	func logIn(userNameOremail: String, password: String) -> Observable<AuthenticationInfo> {
		return Auth0AuthenticationService.authenticate(userNameOremail: userNameOremail, password: password)
			.flatMapLatest { tokens -> Observable<AuthenticationInfo> in
				return Auth0AuthenticationService.userProfile(token: tokens.accessToken)
					.flatMapLatest { profile -> Observable<AuthenticationInfo> in
						return .just(AuthenticationInfo(uid: profile.id, token: tokens.idToken, expiresAt: tokens.expiresAt, refreshToken: tokens.refreshToken))
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
				       scope: "openid profile offline_access", 
				       parameters: ["device": UUID().uuidString])
				.start { result in
					
					switch result {
					case .success(let credentials):
						
						#if DEBUG
							print("token: \(credentials.idToken!)")
						#endif
						
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
