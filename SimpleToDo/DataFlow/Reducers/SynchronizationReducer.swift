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
import RealmSwift

struct SynchronizationReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		let currentState = flowController.currentState.state

		switch (action, currentState.authentication) {
		case (SynchronizationAction.addTask(let task), .authenticated): return add(task: task, currentState: currentState)
		case (SynchronizationAction.updateTask(let task), .authenticated): return update(task: task, currentState: currentState)
		case (SynchronizationAction.deleteTask(let index), .authenticated): return deleteTask(by: index, currentState: currentState)
		case (SynchronizationAction.synchronize, .authenticated): return synchronize(currentState: currentState)
		case (SynchronizationAction.completeTask(let index), .authenticated): return updateTaskCompletionStatus(currentState: currentState, index: index)
		case (SynchronizationAction.updateConfiguration, _): return updateConfiguration(currentState: currentState)
		default: return .empty()
		}
	}
}

extension SynchronizationReducer {
	func updateConfiguration(currentState state: AppState) -> Observable<RxStateType> {
		guard let info = state.authentication.info else { return .empty() }
		
		var newConfig = Realm.Configuration()
		newConfig.fileURL = FileManager.default.realmsDirectory.appendingPathComponent("\(info.uid).realm")
		newConfig.objectTypes = [RealmTask.self]
		
		let newSyncService = SynchronizationService(webService: state.syncService.webService,
		                                            repository: state.syncService.repository.withNew(realmConfiguration: newConfig))
		
		return .just(state.mutation.new(syncService: newSyncService))
	}
	
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
					observer.onNext(state.mutation.new(syncStatus: .failed(error)))
					if error.isNotConnectedToInternet() {
						observer.onError(error)
					}
				},
				    onCompleted: {observer.onNext(state.mutation.new(syncStatus: .completed)) },
				    onDispose: { observer.onCompleted() })
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
