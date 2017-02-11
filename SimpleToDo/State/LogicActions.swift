//
//  Logic.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 02.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RxState
import RxSwift
import Wrap
import Unbox

fileprivate let baseUrl = "https://simpletaskmanager.net:443/api/v1"

func updateTaskActionWork(_ task: Task) -> RxActionWork {
	return RxActionWork { state -> Observable<RxActionResultType> in
		let state = state as! AppState
		return Observable.just(task).flatMapLatest { e -> Observable<[String : Any]> in
			return Observable.just(try wrap(e))
			}
			.flatMapLatest { json -> Observable<RxActionResultType> in
				let headers = ["Authorization": state.logInInfo!.toBasicAuthKey(),
				               "Accept":"application/json",
				               "Content-Type":"application/json; charset=utf-8"]
				
				return state.httpClient.requestData(url: URL(string: "\(baseUrl)/tasks/\(task.uuid)")!,
				                                    method: .put,
				                                    jsonBody: json,
				                                    options: [],
				                                    httpHeaders: headers)
					.flatMap { result -> Observable<RxActionResultType> in
						let updated: Task = try unbox(data: result)
						return Observable.just(RxDefaultActionResult(updated))
				}
		}
	}
}

func reloadTasksActionWork(fromRemote: Bool) -> RxActionWork {
	return RxActionWork { state -> Observable<RxActionResultType> in
		let state = state as! AppState
		
		guard fromRemote else { return Observable.just(RxDefaultActionResult(state.tasks)) }
		
		let headers = ["Authorization": state.logInInfo!.toBasicAuthKey()]
		let request = URLRequest(url: URL(string: "\(baseUrl)/tasks/")!, headers: headers)
		return state.httpClient.requestData(request).flatMap { result -> Observable<RxActionResultType> in
			let entries: [Task] = try unbox(data: result)
			return Observable.just(RxDefaultActionResult(entries))
		}
	}
}

func deleteTaskActionWork(entryId id: Int) -> RxActionWork {
	return RxActionWork { state -> Observable<RxActionResultType> in
		let state = state as! AppState
		let headers = ["Authorization": state.logInInfo!.toBasicAuthKey()]
		let request = URLRequest(url: URL(string: "\(baseUrl)/tasks/\(state.tasks[id].uuid)")!, method: .delete, headers: headers)
		return state.httpClient.requestData(request).flatMap { _ -> Observable<RxActionResultType> in
			return Observable.just(RxDefaultActionResult(id))
		}
	}
}

func addTaskActionWork(task: Task) -> RxActionWork {
	return RxActionWork { state -> Observable<RxActionResultType> in
		let state = state as! AppState
		return Observable.just(task).flatMapLatest { e -> Observable<[String : Any]> in
			return Observable.just(try wrap(e))
			}
			.flatMapLatest { json -> Observable<RxActionResultType> in
				let headers = ["Authorization": state.logInInfo!.toBasicAuthKey(),
				               "Accept":"application/json",
				               "Content-Type":"application/json; charset=utf-8"]
				
				return state.httpClient.requestData(url: URL(string: "\(baseUrl)/tasks")!,
				                                    method: .post,
				                                    jsonBody: json,
				                                    options: [],
				                                    httpHeaders: headers)
					.flatMap { result -> Observable<RxActionResultType> in
						let newEntry: Task = try unbox(data: result)
						return Observable.just(RxDefaultActionResult(newEntry))
				}
		}
	}
}
