//
//  TasksReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 03.06.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

struct TasksReducer : RxReducerType {
	func handle(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
		switch action as? TasksAction {
		case TasksAction.showDeleteTaskAlert?: return currentState.coordinator.handle(action)
		default: return .empty()
		}
	}
}
