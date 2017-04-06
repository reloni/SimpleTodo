//
//  WebService.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 26.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow
import RxHttpClient
import Unbox
import Wrap

final class WebSerivce {
	let httpClient: HttpClientType
	
	init(httpClient: HttpClientType) {
		self.httpClient = httpClient
	}
	
	func loadTasks(tokenHeader: Observable<String>) -> Observable<[Task]> {
		return tokenHeader.flatMapLatest { [weak httpClient] token -> Observable<[Task]> in
			guard let httpClient = httpClient else { return .empty() }
			
			let headers = ["Authorization": "\(token)"]
			let request = URLRequest(url: URL(string: "\(HttpClient.baseUrl)/tasks/")!, headers: headers)
			
			return httpClient.requestData(request).flatMap { result -> Observable<[Task]> in
				return .just(try unbox(data: result))
			}
		}
	}
	
	func delete(task: Task, tokenHeader: Observable<String>) -> Observable<Void> {
		return tokenHeader.flatMapLatest { [weak httpClient] token -> Observable<Void> in
			guard let httpClient = httpClient else { return .empty() }
			
			let headers = ["Authorization": "\(token)"]
			let request = URLRequest(url: URL(string: "\(HttpClient.baseUrl)/tasks/\(task.uuid)")!, method: .delete, headers: headers)
			
			return httpClient.requestData(request).flatMap { _ -> Observable<Void> in
				return .just()
			}
		}
	}
	
	func updateTaskCompletionStatus(task: Task, tokenHeader: Observable<String>) -> Observable<Void> {
		return tokenHeader.flatMapLatest { [weak httpClient] token -> Observable<Void> in
			guard let httpClient = httpClient else { return .empty() }
			
			let headers = ["Authorization": "\(token)"]
			let url = URL(baseUrl: "\(HttpClient.baseUrl)/tasks/\(task.uuid)/ChangeCompletionStatus", parameters: ["completed":"\(!task.completed)"])!
			let request = URLRequest(url: url, method: .post, headers: headers)
			
			return httpClient.requestData(request).flatMap { _ -> Observable<Void> in
				return .just()
			}
		}
	}
	
	func update(task: Task, tokenHeader: Observable<String>) -> Observable<Task> {
		return tokenHeader.flatMapLatest { token -> Observable<(token: String, json: [String : Any])> in
			return .just((token: token, json: try wrap(task)))
			}
			.flatMapLatest { [weak httpClient] result -> Observable<Task> in
				guard let httpClient = httpClient else { return .empty() }
				
				let headers = ["Authorization": "\(result.token)",
					"Accept":"application/json",
					"Content-Type":"application/json; charset=utf-8"]
				
				return httpClient.requestData(url: URL(string: "\(HttpClient.baseUrl)/tasks/\(task.uuid)")!,
				                                               method: .put,
				                                               jsonBody: result.json,
				                                               options: [],
				                                               httpHeaders: headers)
					.flatMap { result -> Observable<Task> in
						return .just(try unbox(data: result))
				}
		}
	}
	
	func add(task: Task, tokenHeader: Observable<String>) -> Observable<Task> {
		return tokenHeader.flatMapLatest { token -> Observable<(token: String, json: [String : Any])> in
			return .just((token: token, json: try wrap(task)))
			}
			.flatMapLatest { [weak httpClient] result -> Observable<Task> in
				guard let httpClient = httpClient else { return .empty() }
				
				let headers = ["Authorization": "\(result.token)",
					"Accept":"application/json",
					"Content-Type":"application/json; charset=utf-8"]
				
				return httpClient.requestData(url: URL(string: "\(HttpClient.baseUrl)/tasks")!,
				                                               method: .post,
				                                               jsonBody: result.json,
				                                               options: [],
				                                               httpHeaders: headers)
					.flatMap { result -> Observable<Task> in
						return .just(try unbox(data: result))
				}
		}
	}
}
