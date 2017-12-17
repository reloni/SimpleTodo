//
//  WebService.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 26.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift
import RxDataFlow
import RxHttpClient
import Unbox
import Wrap

protocol WebServiceType {
	func update(with instruction: BatchUpdate, tokenHeader: String) -> Observable<[Task]>
	func deleteUser(tokenHeader: String) -> Observable<Void>
	func logOut(refreshToken: String, tokenHeader: String) -> Observable<Void>
	func withNew(host: String) -> WebServiceType
}

final class WebSerivce: WebServiceType {
	let httpClient: HttpClientType
	let host: String
	
	init(httpClient: HttpClientType, host: String) {
		self.httpClient = httpClient
		self.host = host
	}
	
	func withNew(host: String) -> WebServiceType {
		return WebSerivce(httpClient: httpClient, host: host)
	}
	
	private static func catchError<T>(error: Error) -> Observable<T> {
		switch error {
		case HttpClientError.invalidResponse(let response, _) where response.statusCode == 401:
			return .error(AuthenticationError.notAuthorized)
		default: return Observable.error(error)
		}
	}
	
	private func headers(withToken token: String) -> [String: String] {
		return ["Authorization": "\(token)",
			"Accept":"application/json",
			"Accept-Encoding":"gzip",
			"Content-Type":"application/json; charset=utf-8",
			"Host": host]
	}
	
	func deleteUser(tokenHeader: String) -> Observable<Void> {
		let request = URLRequest(url: URL(string: "\(AppConstants.baseUrl)/users")!,
		                         method: .delete,
		                         headers: headers(withToken: tokenHeader))
		
		return httpClient.requestData(request, requestCacheMode: CacheMode.withoutCache)
			.flatMap { _ -> Observable<Void> in
				return .just(())
			}
			.catchError(WebSerivce.catchError)
	}
	
	func logOut(refreshToken: String, tokenHeader: String) -> Observable<Void> {
		let request = URLRequest(url: URL(string: "\(AppConstants.baseUrl)/users/LogOut")!,
		                         method: .post,
		                         jsonBody: ["RefreshToken": refreshToken],
		                         headers: headers(withToken: tokenHeader))!
		
		return httpClient.requestData(request, requestCacheMode: CacheMode.withoutCache)
			.flatMap { _ -> Observable<Void> in
				return .just(())
			}
			.catchError(WebSerivce.catchError)
	}
	
	func update(with instruction: BatchUpdate, tokenHeader: String) -> Observable<[Task]> {
		guard let json = try? wrap(instruction) else { return .empty() }
		let request = URLRequest(url: URL(string: "\(AppConstants.baseUrl)/tasks/BatchUpdate")!,
		                         method: .post,
		                         jsonBody: json,
		                         options: [],
		                         headers: headers(withToken: tokenHeader))!
		
		return httpClient.requestData(request, requestCacheMode: CacheMode.withoutCache)
			.flatMap { result -> Observable<[Task]> in
				return .just(try JSONDecoder().decode([Task].self, from: result))
			}
			.catchError(WebSerivce.catchError)
	}
}

