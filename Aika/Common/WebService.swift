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
	func loadTasks(tokenHeader: Observable<String>) -> Observable<[Task]>
	func delete(task: Task, tokenHeader: Observable<String>) -> Observable<Void>
	func updateTaskCompletionStatus(task: Task, tokenHeader: Observable<String>) -> Observable<Void>
	func update(task: Task, tokenHeader: Observable<String>) -> Observable<Task>
	func add(task: Task, tokenHeader: Observable<String>) -> Observable<Task>
	func update(with instruction: BatchUpdate, tokenHeader: Observable<String>) -> Observable<[Task]>
	func deleteUser(tokenHeader: Observable<String>) -> Observable<Void>
}

final class WebSerivce: WebServiceType {
	let httpClient: HttpClientType
	
	init(httpClient: HttpClientType) {
		self.httpClient = httpClient
	}
	
	private static func catchError<T>(error: Error) -> Observable<T> {
		switch error {
		case HttpClientError.invalidResponse(let response, _) where response.statusCode == 401:
			return .error(AuthenticationError.notAuthorized)
		default: return Observable.error(error)
		}
	}
	
	private static func headers(withToken token: String) -> [String: String] {
		return ["Authorization": "\(token)",
			"Accept":"application/json",
			"Content-Type":"application/json; charset=utf-8"]
	}
	
	func loadTasks(tokenHeader: Observable<String>) -> Observable<[Task]> {
		return tokenHeader.flatMapLatest { [weak httpClient] token -> Observable<[Task]> in
			guard let httpClient = httpClient else { return .empty() }
			
			let headers = ["Authorization": "\(token)"]
			let request = URLRequest(url: URL(string: "\(HttpClient.baseUrl)/tasks/")!, headers: headers)
			
			return httpClient.requestData(request, requestCacheMode: CacheMode.withoutCache).flatMap { result -> Observable<[Task]> in
				return .just(try unbox(data: result))
			}
		}
		.catchError(WebSerivce.catchError)
	}
	
	func delete(task: Task, tokenHeader: Observable<String>) -> Observable<Void> {
		return tokenHeader.flatMapLatest { [weak httpClient] token -> Observable<Void> in
			guard let httpClient = httpClient else { return .empty() }
			
			let request = URLRequest(url: URL(string: "\(HttpClient.baseUrl)/tasks/\(task.uuid)")!, method: .delete, headers: WebSerivce.headers(withToken: token))
			
			return httpClient.requestData(request, requestCacheMode: CacheMode.withoutCache).flatMap { _ -> Observable<Void> in
				return .just()
			}
		}
		.catchError(WebSerivce.catchError)
	}
	
	func updateTaskCompletionStatus(task: Task, tokenHeader: Observable<String>) -> Observable<Void> {
		return tokenHeader.flatMapLatest { [weak httpClient] token -> Observable<Void> in
			guard let httpClient = httpClient else { return .empty() }
			
			let url = URL(baseUrl: "\(HttpClient.baseUrl)/tasks/\(task.uuid)/ChangeCompletionStatus", parameters: ["completed":"\(!task.completed)"])!
			let request = URLRequest(url: url, method: .post, headers: WebSerivce.headers(withToken: token))
			
			return httpClient.requestData(request, requestCacheMode: CacheMode.withoutCache).flatMap { _ -> Observable<Void> in
				return .just()
			}
		}
		.catchError(WebSerivce.catchError)
	}
	
	func update(task: Task, tokenHeader: Observable<String>) -> Observable<Task> {
		return tokenHeader.flatMapLatest { token -> Observable<(token: String, json: [String : Any])> in
			return .just((token: token, json: try wrap(task)))
			}
			.flatMapLatest { [weak httpClient] result -> Observable<Task> in
				guard let httpClient = httpClient else { return .empty() }
				
				let request = URLRequest(url: URL(string: "\(HttpClient.baseUrl)/tasks/\(task.uuid)")!,
				                         method: .put,
				                         jsonBody: result.json,
				                         options: [],
				                         headers: WebSerivce.headers(withToken: result.token))!
				
				return httpClient.requestData(request, requestCacheMode: CacheMode.withoutCache)
					.flatMap { result -> Observable<Task> in
						return .just(try unbox(data: result))
				}
		}
		.catchError(WebSerivce.catchError)
	}
	
	func add(task: Task, tokenHeader: Observable<String>) -> Observable<Task> {
		return tokenHeader.flatMapLatest { token -> Observable<(token: String, json: [String : Any])> in
			return .just((token: token, json: try wrap(task)))
			}
			.flatMapLatest { [weak httpClient] result -> Observable<Task> in
				guard let httpClient = httpClient else { return .empty() }
				
				let request = URLRequest(url: URL(string: "\(HttpClient.baseUrl)/tasks")!,
				                         method: .post,
				                         jsonBody: result.json,
				                         options: [],
				                         headers: WebSerivce.headers(withToken: result.token))!
				
				return httpClient.requestData(request, requestCacheMode: CacheMode.withoutCache)
					.flatMap { result -> Observable<Task> in
						return .just(try unbox(data: result))
				}
		}
		.catchError(WebSerivce.catchError)
	}
	
	func deleteUser(tokenHeader: Observable<String>) -> Observable<Void> {
		return tokenHeader
			.flatMapLatest { [weak httpClient] token -> Observable<Void> in
				guard let httpClient = httpClient else { return .empty() }
				
				let request = URLRequest(url: URL(string: "\(HttpClient.baseUrl)/users")!,
				                         method: .delete,
				                         headers: WebSerivce.headers(withToken: token))
				
				return httpClient.requestData(request, requestCacheMode: CacheMode.withoutCache)
					.flatMap { _ -> Observable<Void> in
						return .just()
				}
			}
			.catchError(WebSerivce.catchError)
	}
	
	func update(with instruction: BatchUpdate, tokenHeader: Observable<String>) -> Observable<[Task]> {
		return tokenHeader.flatMapLatest { token -> Observable<(token: String, json: [String : Any])> in
			return .just((token: token, json: try wrap(instruction)))
		}
		.flatMapLatest { [weak httpClient] result -> Observable<[Task]> in
			guard let httpClient = httpClient else { return .empty() }
			
			let request = URLRequest(url: URL(string: "\(HttpClient.baseUrl)/tasks/BatchUpdate")!,
			                         method: .post,
			                         jsonBody: result.json,
			                         options: [],
			                         headers: WebSerivce.headers(withToken: result.token))!
			
			return httpClient.requestData(request, requestCacheMode: CacheMode.withoutCache)
							.flatMap { result -> Observable<[Task]> in return .just(try unbox(data: result)) }
		}
		.catchError(WebSerivce.catchError)
	}
}

