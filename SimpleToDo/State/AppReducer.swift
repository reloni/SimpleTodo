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
		case .loadToDoEntries: return Observable.just(currentState.new(toDoEntries: (actionResult as! RxDefaultActionResult).value))
		case .addToDoEntry:
			var currentEntries = currentState.toDoEntries
			currentEntries[0] = ToDoEntry(id: currentEntries[0].id, completed: true, description: "UPDATED!!!!!", notes: nil)
			currentEntries.append((actionResult as! RxDefaultActionResult).value)
			return Observable.just(currentState.new(toDoEntries: currentEntries))
		case .deleteToDoEntry:
			var currentEntries = currentState.toDoEntries
			currentEntries.remove(at: (actionResult as! RxDefaultActionResult).value)
			return Observable.just(currentState.new(toDoEntries: currentEntries))
		case .reloadToDoEntries: return Observable.just(currentState.new(toDoEntries: (actionResult as! RxDefaultActionResult).value))
		case .showError: return Observable.empty()
		case .editToDoEntry: return Observable.empty()
		}
	}
}
