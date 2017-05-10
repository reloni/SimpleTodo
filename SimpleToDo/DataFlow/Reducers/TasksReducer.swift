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

//struct TasksReducer : RxReducerType {
//	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
//		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
//	}
//	
//	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
//		let currentState = flowController.currentState.state
//		switch action {
//		case _ as EditTaskAction: return EditTaskReducer().handle(action, flowController: flowController)
//		case TaskListAction.loadTasks: return reloadTasks(currentState: currentState, fromRemote: true)
//		case TaskListAction.deleteTask(let index): return deleteTask(currentState: currentState, index: index)
//		case TaskListAction.completeTask(let index): return updateTaskCompletionStatus(currentState: currentState, index: index)
//		default: return .empty()
//		}
//	}
//}
//
//extension TasksReducer {
//	func reloadTasks(currentState state: AppState, fromRemote: Bool) -> Observable<RxStateType> {
//		guard fromRemote else { return Observable.just(state) }
//
////		state.syncService.addOrUpdate(task: task)
//		return .just(state)
////		return state.syncService.webService.loadTasks(tokenHeader: state.authentication.tokenHeader).flatMapLatest { tasks -> Observable<RxStateType> in
////			tasks.forEach { state.syncService.addOrUpdate(task: $0) }
////			return .just(state)
////		}
//	}
//	
//	func deleteTask(currentState state: AppState, index: Int) -> Observable<RxStateType> {
//		//let taskToDelete = state.syncService.task(for: index).toStruct()
//		//state.syncService.delete(task: taskToDelete)
//		state.syncService.delete(taskIndex: index)
//		return .just(state)
////		return state.syncService.webService.delete(task: taskToDelete, tokenHeader: state.authentication.tokenHeader).flatMap { _ -> Observable<RxStateType> in
////			state.syncService.delete(task: taskToDelete)
////			return .just(state)
////		}
//	}
//	
//	func updateTaskCompletionStatus(currentState state: AppState, index: Int) -> Observable<RxStateType> {
//		let taskToComplete = state.syncService.task(for: index)
//		taskToComplete.completed = true
//		state.syncService.addOrUpdate(task: taskToComplete.toStruct())
//		return .just(state)
////		return state.syncService.webService.updateTaskCompletionStatus(task: taskToDelete, tokenHeader: state.authentication.tokenHeader)
////			.flatMap { updated -> Observable<RxStateType> in
////				state.syncService.delete(task: taskToDelete)
////				return .just(state)
////			}
//	}
//}
