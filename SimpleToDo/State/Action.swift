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
	case deleteToDoEntry(Int)
	case showError(Error)
	
	var work: (RxStateType) -> Observable<RxActionResultType> {
		switch self {
		case .reloadToDoEntries: return reload(fromRemote: false)
		case .loadToDoEntries: return reload(fromRemote: true)
		case .deleteToDoEntry(let id): return delete(entryId: id)
		case .addToDoEntry(let entry): return add(entry: entry)
		case .showError(let e): return showErrorMessage(e)
		}
	}
}

func showErrorMessage(_ error: Error) -> (RxStateType) -> Observable<RxActionResultType> {
	return { state in
		let state = state as! AppState
		state.rootController.showError(error: error)
		return Observable.empty()
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
		let request = URLRequest(url: URL(string: "http://localhost:5000/api/todoentries/\(state.toDoEntries[id].id + 100)")!, method: .delete, headers: headers)
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
