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
		case .loadTasks: return Observable.just(currentState.new(tasks: (actionResult as! RxDefaultActionResult).value))
		case .addTask:
			var currentEntries = currentState.tasks
			currentEntries.append((actionResult as! RxDefaultActionResult).value)
			return Observable.just(currentState.new(tasks: currentEntries))
		case .deleteTask:
			var currentEntries = currentState.tasks
			currentEntries.remove(at: (actionResult as! RxDefaultActionResult).value)
			return Observable.just(currentState.new(tasks: currentEntries))
		case .reloadTasks: return Observable.just(currentState.new(tasks: (actionResult as! RxDefaultActionResult).value))
		case .showAllert: return Observable.empty()
		case .showEditTaskController: return Observable.empty()
		case .dismisEditTaskController: return Observable.empty()
		case .updateTask:
			let updated: Task = (actionResult as! RxDefaultActionResult).value
			let newEntries = currentState.tasks.map { t -> Task in
				if t.uuid == updated.uuid {
					return updated
				} else {
					return t
				}
			}
			return Observable.just(currentState.new(tasks: newEntries))
		case .completeTask:
			var currentTasks = currentState.tasks
			currentTasks.remove(at: (actionResult as! RxDefaultActionResult).value)
			return Observable.just(currentState.new(tasks: currentTasks))
 		}
	}
}
