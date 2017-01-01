//
//  State.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 18.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import RxState
import RxSwift
import RxHttpClient
import Unbox
import UIKit
import Wrap

struct AppState : RxStateType {
	let rootController: MainController
	let logInInfo: LogInInfo?
	let httpClient: HttpClientType
	let toDoEntries: [ToDoEntry]
}

extension AppState {
	func new(toDoEntries: [ToDoEntry]) -> AppState {
		return AppState(rootController: rootController, logInInfo: logInInfo, httpClient: httpClient, toDoEntries: toDoEntries)
	}
}

enum AppAction : RxActionType {
	case reloadToDoEntries([ToDoEntry])
	case loadToDoEntries
	case addToDoEntry(ToDoEntry)
	case showEditEntryController(ToDoEntry)
	case dismisEditEntryController
	case deleteToDoEntry(Int)
	case showError(Error)
	case updateEntry(ToDoEntry)
	
	var work: RxActionWork {
		switch self {
		case .reloadToDoEntries: return reloadActionWork(fromRemote: false)
		case .loadToDoEntries: return reloadActionWork(fromRemote: true)
		case .deleteToDoEntry(let id): return deleteActionWork(entryId: id)
		case .addToDoEntry(let entry): return addActionWork(entry: entry)
		case .showEditEntryController(let entry): return showEditEntryControllerActionWork(entry)
		case .dismisEditEntryController: return dismisEditEntryControllerActionWork()
		case .updateEntry(let entry): return updateEntryActionWork(entry)
		case .showError(let e): return showErrorMessageActionWork(e)
		}
	}
}

func dismisEditEntryControllerActionWork() -> RxActionWork {
	return RxActionWork(scheduler: MainScheduler.instance) { state -> RxActionResultType in
		let state = state as! AppState
		state.rootController.popViewController(animated: true)
		return RxDefaultActionResult()
	}
}

func updateEntryActionWork(_ entry: ToDoEntry) -> RxActionWork {
	return RxActionWork { state -> Observable<RxActionResultType> in
		let state = state as! AppState
		return Observable.just(entry).flatMapLatest { e -> Observable<[String : Any]> in
			return Observable.just(try wrap(e))
			}
			.flatMapLatest { json -> Observable<RxActionResultType> in
				let headers = ["Authorization": state.logInInfo!.toBasicAuthKey(),
				               "Accept":"application/json",
				               "Content-Type":"application/json; charset=utf-8"]
				
				return state.httpClient.requestData(url: URL(string: "http://localhost:5000/api/todoentries/\(entry.id)")!,
				                                    method: .put,
				                                    jsonBody: json,
				                                    options: [],
				                                    httpHeaders: headers)
					.flatMap { result -> Observable<RxActionResultType> in
						let updated: ToDoEntry = try unbox(data: result)
						let newTodos = state.toDoEntries.map { t -> ToDoEntry in
							if t.id == updated.id {
								return updated
							} else {
								return t
							}
						}
						return Observable.just(RxDefaultActionResult(newTodos))
				}
		}
	}
}

func showErrorMessageActionWork(_ error: Error) -> RxActionWork {
	return RxActionWork(scheduler: MainScheduler.instance) { state -> RxActionResultType in
		let state = state as! AppState
		state.rootController.showError(error: error)
		return RxDefaultActionResult()
	}
}

func showEditEntryControllerActionWork(_ entry: ToDoEntry) -> RxActionWork {
	return RxActionWork(scheduler: MainScheduler.instance) { state -> RxActionResultType in
		let state = state as! AppState
		state.rootController.pushViewController(EditToDoEntryController(entry: entry), animated: true)
		return RxDefaultActionResult()
	}
}

func reloadActionWork(fromRemote: Bool) -> RxActionWork {
	return RxActionWork { state -> Observable<RxActionResultType> in
		let state = state as! AppState
		
		guard fromRemote else { return Observable.just(RxDefaultActionResult(state.toDoEntries)) }
		
		let headers = ["Authorization": state.logInInfo!.toBasicAuthKey()]
		let request = URLRequest(url: URL(string: "http://localhost:5000/api/todoentries/")!, headers: headers)
		return state.httpClient.requestData(request).flatMap { result -> Observable<RxActionResultType> in
			let entries: [ToDoEntry] = try unbox(data: result)
			return Observable.just(RxDefaultActionResult(entries))
		}
	}
}

func deleteActionWork(entryId id: Int) -> RxActionWork {
	return RxActionWork { state -> Observable<RxActionResultType> in
		let state = state as! AppState
		let headers = ["Authorization": state.logInInfo!.toBasicAuthKey()]
		let request = URLRequest(url: URL(string: "http://localhost:5000/api/todoentries/\(state.toDoEntries[id].id + 100)")!, method: .delete, headers: headers)
		return state.httpClient.requestData(request).flatMap { _ -> Observable<RxActionResultType> in
			return Observable.just(RxDefaultActionResult(id))
		}
	}
}

func addActionWork(entry: ToDoEntry) -> RxActionWork {
	return RxActionWork { state in
		return Observable.create { observer in
			fatalError("shit happens")
			let state = state as! AppState
			state.rootController.popViewController(animated: true)
			observer.onCompleted()
			return Disposables.create()
			}.subscribeOn(MainScheduler.instance)
	}
}
