//
//  EditTaskReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 12.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow
import RxHttpClient
import Wrap
import Unbox

struct EditTaskReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		let currentState = flowController.currentState.state
		switch action {
		case EditTaskAction.dismisEditTaskController: return currentState.coordinator.handle(action, flowController: flowController)
		case EditTaskAction.addTask(let task): return addTask(task: task, currentState: currentState)
		case EditTaskAction.updateTask(let task): return updateTask(task, currentState: currentState)
		default: return .empty()
		}
	}
}

extension EditTaskReducer {
	func updateTask(_ task: Task, currentState state: AppState) -> Observable<RxStateType> {
		return Observable.just(task).flatMapLatest { e -> Observable<[String : Any]> in
			return Observable.just(try wrap(e))
			}
			.flatMapLatest { json -> Observable<RxStateType> in
				let headers = ["Authorization": state.logInInfo!.toBasicAuthKey(),
				               "Accept":"application/json",
				               "Content-Type":"application/json; charset=utf-8"]
				
				return state.httpClient.requestData(url: URL(string: "\(HttpClient.baseUrl)/tasks/\(task.uuid)")!,
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
	
	func addTask(task: Task, currentState state: AppState) -> Observable<RxStateType> {
		return Observable.just(task).flatMapLatest { e -> Observable<[String : Any]> in
			return Observable.just(try wrap(e))
			}
			.flatMapLatest { json -> Observable<RxStateType> in
				let headers = ["Authorization": state.logInInfo!.toBasicAuthKey(),
				               "Accept":"application/json",
				               "Content-Type":"application/json; charset=utf-8"]
				
				return state.httpClient.requestData(url: URL(string: "\(HttpClient.baseUrl)/tasks")!,
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
