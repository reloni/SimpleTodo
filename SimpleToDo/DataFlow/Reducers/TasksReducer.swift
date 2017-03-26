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
		case TaskListAction.showEditTaskController: return currentState.coordinator.handle(action, flowController: flowController)
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
			return .just(state.mutation.new(tasks: tasks))
		}
	}
	
	func deleteTask(currentState state: AppState, index: Int) -> Observable<RxStateType> {
		return state.webService.delete(task: state.tasks[index], tokenHeader: state.authentication.tokenHeader).flatMap { _ -> Observable<RxStateType> in
			var currentEntries = state.tasks
			currentEntries.remove(at: index)
			return Observable.just(state.mutation.new(tasks: currentEntries))
		}
	}
	
	func updateTaskCompletionStatus(currentState state: AppState, index: Int) -> Observable<RxStateType> {
		return state.webService.updateTaskCompletionStatus(task: state.tasks[index], tokenHeader: state.authentication.tokenHeader)
			.flatMap { _ -> Observable<RxStateType> in
				var currentTasks = state.tasks
				currentTasks.remove(at: index)
				return Observable.just(state.mutation.new(tasks: currentTasks))
			}
	}
}
