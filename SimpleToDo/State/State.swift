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
	let toDoEntries: [ToDoEntry]
}

struct LoadToDoEntriesAction : RxActionType {
	let httpClient: HttpClientType
	let urlRequest: URLRequest
	var work: () -> Observable<RxActionResultType> {
		return {
			return self.httpClient.requestData(self.urlRequest).flatMap { result -> Observable<RxActionResultType> in
				sleep(2)
				let entries: [ToDoEntry] = try unbox(data: result)
				return Observable.just(DefaultActionResult(entries))
			}
		}
	}
}

struct AddToDoEntryAction : RxActionType {
	let newItem: ToDoEntry
	var work: () -> Observable<RxActionResultType> {
		return {
			Observable.just(DefaultActionResult(self.newItem))
		}
	}
}

struct AppReducer : RxReducerType {
	func handle(_ action: RxActionType, actionResult: RxActionResultType, currentState: RxStateType) -> Observable<RxStateType> {
		let currentState = currentState as! AppState
		print("handle new action: \(action.self)")
		switch action {
		case _ as LoadToDoEntriesAction: return Observable.just(AppState(toDoEntries: (actionResult as! DefaultActionResult).value))
		case _ as AddToDoEntryAction:
			var currentEntries = currentState.toDoEntries
			currentEntries.append((actionResult as! DefaultActionResult).value)
			return Observable.just(AppState(toDoEntries: currentEntries))
		default: return Observable.empty()
		}
	}
}
