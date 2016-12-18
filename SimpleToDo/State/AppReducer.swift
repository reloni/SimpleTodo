//
//  AppReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 18.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxState

struct AppReducer : RxReducerType {
	func handle(_ action: RxActionType, actionResult: RxActionResultType, currentState: RxStateType) -> Observable<RxStateType> {
		let currentState = currentState as! AppState
		let action = action as! AppAction
		print("handle new action: \(action.self)")
		switch action {
		case .loadToDoEntries: return Observable.just(AppState(toDoEntries: (actionResult as! DefaultActionResult).value))
		case .addToDoEntry:
			var currentEntries = currentState.toDoEntries
			currentEntries[0] = ToDoEntry(id: currentEntries[0].id, completed: true, description: "UPDATED!!!!!", notes: nil)
			currentEntries.append((actionResult as! DefaultActionResult).value)
			return Observable.just(AppState(toDoEntries: currentEntries))
		case .deleteToDoEntry:
			var currentEntries = currentState.toDoEntries
			currentEntries.remove(at: (actionResult as! DefaultActionResult).value)
			return Observable.just(AppState(toDoEntries: currentEntries))
		case .reloadToDoEntries: return Observable.just(AppState(toDoEntries: (actionResult as! DefaultActionResult).value))
		}
	}
}
