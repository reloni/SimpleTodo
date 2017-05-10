//
//  SynchronizationReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 10.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift
import RxDataFlow

struct SynchronizationReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		let currentState = flowController.currentState.state
		switch action {
		case SynchronizationAction.addTask(let task): return add(task: task, currentState: currentState)
		case SynchronizationAction.updateTask(let task): return update(task: task, currentState: currentState)
		case SynchronizationAction.deleteTask(let index): return deleteTask(by: index, currentState: currentState)
		case SynchronizationAction.synchronize: return synchronize(currentState: currentState)
		case SynchronizationAction.completeTask(let index): return updateTaskCompletionStatus(currentState: currentState, index: index)
		default: return .empty()
		}
	}
}

extension SynchronizationReducer {
	func update(task: Task, currentState state: AppState) -> Observable<RxStateType> {
		state.syncService.addOrUpdate(task: task)
		return .just(state)
	}
	
	func add(task: Task, currentState state: AppState) -> Observable<RxStateType> {
		state.syncService.addOrUpdate(task: task)
		return .just(state)
	}
	
	func synchronize(currentState state: AppState) -> Observable<RxStateType> {
		guard let info = state.authentication.info else { return .empty() }
		
		return Observable.create { observer in
			observer.onNext(state.mutation.new(syncStatus: .inProgress))
			
			let subscription = state.syncService.synchronize(authenticationInfo: info)
				.do(onError: { error in
					print("sync error: \(error)")
					observer.onNext(state.mutation.new(syncStatus: .failed(error)))
				},
				    onCompleted: {
							print("sync complete")
							observer.onNext(state.mutation.new(syncStatus: .completed))
				},
				    onDispose: {
							print("sync dispose")
							observer.onCompleted()
				})
				.subscribe()
			
			return Disposables.create {
				subscription.dispose()
			}
		}
	}
	
	func deleteTask(by index: Int, currentState state: AppState) -> Observable<RxStateType> {
		state.syncService.delete(taskIndex: index)
		return .just(state)
	}
	
	func updateTaskCompletionStatus(currentState state: AppState, index: Int) -> Observable<RxStateType> {
		state.syncService.complete(taskIndex: index)
		return .just(state)
	}
}
