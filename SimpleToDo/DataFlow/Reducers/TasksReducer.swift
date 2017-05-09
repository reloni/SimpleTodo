//
//  TasksReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 12.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow
import RxHttpClient
import Unbox

struct TasksReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		let currentState = flowController.currentState.state
		switch action {
		case _ as EditTaskAction: return EditTaskReducer().handle(action, flowController: flowController)
		case TaskListAction.loadTasks: return reloadTasks(currentState: currentState, fromRemote: true)
		case TaskListAction.deleteTask(let index): return deleteTask(currentState: currentState, index: index)
		case TaskListAction.completeTask(let index): return updateTaskCompletionStatus(currentState: currentState, index: index)
		default: return .empty()
		}
	}
}

extension TasksReducer {
	func reloadTasks(currentState state: AppState, fromRemote: Bool) -> Observable<RxStateType> {
		guard fromRemote else { return Observable.just(state) }
		
		return state.webService.loadTasks(tokenHeader: state.authentication.tokenHeader).flatMapLatest { tasks -> Observable<RxStateType> in
			tasks.forEach { _ = try! state.repository.addOrUpdate(task: $0) }
			return .just(state)
		}
	}
	
	func deleteTask(currentState state: AppState, index: Int) -> Observable<RxStateType> {
		let taskToDelete = state.repository.tasks()[index].toStruct()
		return state.webService.delete(task: taskToDelete, tokenHeader: state.authentication.tokenHeader).flatMap { _ -> Observable<RxStateType> in
			_ = try! state.repository.delete(task: taskToDelete)
			return .just(state)
		}
	}
	
	func updateTaskCompletionStatus(currentState state: AppState, index: Int) -> Observable<RxStateType> {
		let taskToDelete = state.repository.tasks()[index].toStruct()
		return state.webService.updateTaskCompletionStatus(task: state.repository.tasks()[index].toStruct(), tokenHeader: state.authentication.tokenHeader)
			.flatMap { updated -> Observable<RxStateType> in
				_ = try! state.repository.delete(task: taskToDelete)
				return .just(state)
			}
	}
}
