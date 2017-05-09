//
//  EditTaskReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 12.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow
import RxHttpClient
import Wrap
import Unbox

struct EditTaskReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		let currentState = flowController.currentState.state
		switch action {
		case EditTaskAction.addTask(let task): return add(task: task, currentState: currentState)
		case EditTaskAction.updateTask(let task): return update(task: task, currentState: currentState)
		default: return .empty()
		}
	}
}

extension EditTaskReducer {
	func update(task: Task, currentState state: AppState) -> Observable<RxStateType> {
		return state.syncService.webService.update(task: task, tokenHeader: state.authentication.tokenHeader).flatMap { updated -> Observable<RxStateType> in
			state.syncService.addOrUpdate(task: updated)
			
			return .just(state)
		}
	}
	
	func add(task: Task, currentState state: AppState) -> Observable<RxStateType> {
		return state.syncService.webService.add(task: task, tokenHeader: state.authentication.tokenHeader).flatMap { added -> Observable<RxStateType> in
			state.syncService.addOrUpdate(task: added)
			return .just(state)
		}
	}
}
