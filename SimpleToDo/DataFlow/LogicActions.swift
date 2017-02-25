//
//  Logic.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 02.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RxDataFlow
import RxSwift
import Wrap
import Unbox

struct ApplicationLogic {
	fileprivate static let baseUrl = "https://simpletaskmanager.net:443/api/v1"
	
	static func updateTask(_ task: Task, currentState state: AppState) -> Observable<RxStateType> {
			return Observable.just(task).flatMapLatest { e -> Observable<[String : Any]> in
				return Observable.just(try wrap(e))
				}
				.flatMapLatest { json -> Observable<RxStateType> in
					let headers = ["Authorization": state.logInInfo!.toBasicAuthKey(),
					               "Accept":"application/json",
					               "Content-Type":"application/json; charset=utf-8"]
					
					return state.httpClient.requestData(url: URL(string: "\(baseUrl)/tasks/\(task.uuid)")!,
					                                    method: .put,
					                                    jsonBody: json,
					                                    options: [],
					                                    httpHeaders: headers)
						.flatMap { result -> Observable<RxStateType> in
							let updated: Task = try unbox(data: result)
							
							let newTasks = state.tasks.map { t -> Task in
								if t.uuid == updated.uuid {
									return updated
								} else {
									return t
								}
							}
							
							return .just(state.mutation.new(tasks: newTasks))
					}
			}
	}
	
	static func reloadTasks(currentState state: AppState, fromRemote: Bool) -> Observable<RxStateType> {
		guard fromRemote else { return Observable.just(state) }
		
		let headers = ["Authorization": state.logInInfo!.toBasicAuthKey()]
		let request = URLRequest(url: URL(string: "\(baseUrl)/tasks/")!, headers: headers)
		
		return state.httpClient.requestData(request).flatMap { result -> Observable<RxStateType> in
			return .just(state.mutation.new(tasks: try unbox(data: result)))
		}
	}
	
	static func deleteTask(currentState state: AppState, entryId id: Int) -> Observable<RxStateType> {
		let headers = ["Authorization": state.logInInfo!.toBasicAuthKey()]
		let request = URLRequest(url: URL(string: "\(baseUrl)/tasks/\(state.tasks[id].uuid)")!, method: .delete, headers: headers)
		
		return state.httpClient.requestData(request).flatMap { _ -> Observable<RxStateType> in
			var currentEntries = state.tasks
			currentEntries.remove(at: id)
			return Observable.just(state.mutation.new(tasks: currentEntries))
		}
	}
	
	static func updateTaskCompletionStatus(currentState state: AppState, taskIndex index: Int) -> Observable<RxStateType> {
		let headers = ["Authorization": state.logInInfo!.toBasicAuthKey()]
		let task = state.tasks[index]
		
		let url = URL(baseUrl: "\(baseUrl)/tasks/\(task.uuid)/ChangeCompletionStatus", parameters: ["completed":"\(!task.completed)"])!
		let request = URLRequest(url: url, method: .post, headers: headers)
		return state.httpClient.requestData(request).flatMap { _ -> Observable<RxStateType> in
			var currentTasks = state.tasks
			currentTasks.remove(at: index)
			return Observable.just(state.mutation.new(tasks: currentTasks))
		}
	}
	
	static func addTask(task: Task, currentState state: AppState) -> Observable<RxStateType> {
		return Observable.just(task).flatMapLatest { e -> Observable<[String : Any]> in
			return Observable.just(try wrap(e))
			}
			.flatMapLatest { json -> Observable<RxStateType> in
				let headers = ["Authorization": state.logInInfo!.toBasicAuthKey(),
				               "Accept":"application/json",
				               "Content-Type":"application/json; charset=utf-8"]
				
				return state.httpClient.requestData(url: URL(string: "\(baseUrl)/tasks")!,
				                                    method: .post,
				                                    jsonBody: json,
				                                    options: [],
				                                    httpHeaders: headers)
					.flatMap { result -> Observable<RxStateType> in
						var currentTasks = state.tasks
						currentTasks.append(try unbox(data: result))
						return Observable.just(state.mutation.new(tasks: currentTasks))
				}
		}
	}
	
}


