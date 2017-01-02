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
			currentEntries.append((actionResult as! RxDefaultActionResult).value)
			return Observable.just(currentState.new(toDoEntries: currentEntries))
		case .deleteToDoEntry:
			var currentEntries = currentState.toDoEntries
			currentEntries.remove(at: (actionResult as! RxDefaultActionResult).value)
			return Observable.just(currentState.new(toDoEntries: currentEntries))
		case .reloadToDoEntries: return Observable.just(currentState.new(toDoEntries: (actionResult as! RxDefaultActionResult).value))
		case .showAllert: return Observable.empty()
		case .showEditEntryController: return Observable.empty()
		case .dismisEditEntryController: return Observable.empty()
		case .updateEntry:
			let updated: ToDoEntry = (actionResult as! RxDefaultActionResult).value
			let newEntries = currentState.toDoEntries.map { t -> ToDoEntry in
				if t.id == updated.id {
					return updated
				} else {
					return t
				}
			}
			return Observable.just(currentState.new(toDoEntries: newEntries))
		}
	}
}
