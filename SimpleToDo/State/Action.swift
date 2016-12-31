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

struct AppState : RxStateType {
	let logInInfo: LogInInfo?
	let httpClient: HttpClientType
	let toDoEntries: [ToDoEntry]
}

extension AppState {
	func new(toDoEntries: [ToDoEntry]) -> AppState {
		return AppState(logInInfo: logInInfo, httpClient: httpClient, toDoEntries: toDoEntries)
	}
}

enum AppAction : RxActionType {
	case reloadToDoEntries([ToDoEntry])
	case loadToDoEntries
	case addToDoEntry(ToDoEntry)
	case deleteToDoEntry(Int)
	
	var work: (RxStateType) -> Observable<RxActionResultType> {
		switch self {
		case .reloadToDoEntries: return reload(fromRemote: false)
		case .loadToDoEntries: return reload(fromRemote: true)
		case .deleteToDoEntry(let id): return delete(entryId: id)
		case .addToDoEntry(let entry): return add(entry: entry)
		}
	}
}

func reload(fromRemote: Bool) -> (RxStateType) -> Observable<RxActionResultType> {
	return { state -> Observable<RxActionResultType> in
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

func delete(entryId id: Int) -> (RxStateType) -> Observable<RxActionResultType> {
	return { state -> Observable<RxActionResultType> in
		let state = state as! AppState
		let headers = ["Authorization": state.logInInfo!.toBasicAuthKey()]
		let request = URLRequest(url: URL(string: "http://localhost:5000/api/todoentries/\(state.toDoEntries[id].id)")!, method: .delete, headers: headers)
		return state.httpClient.requestData(request).flatMap { _ -> Observable<RxActionResultType> in
			return Observable.just(RxDefaultActionResult(id))
		}
	}
}

func add(entry: ToDoEntry) -> (RxStateType) -> Observable<RxActionResultType> {
	return { _ in
		Observable.just(RxDefaultActionResult(entry))
	}
}
