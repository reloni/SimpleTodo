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
import RxHttpClient

func synchronizationReducer(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
	switch (action, currentState.authentication) {
	case (SynchronizationAction.addTask(let task), .authenticated): return add(task: task, currentState: currentState)
	case (SynchronizationAction.updateTask(let task), .authenticated): return update(task: task, currentState: currentState)
	case (SynchronizationAction.deleteTask(let uuid), .authenticated): return deleteTask(by: uuid, currentState: currentState)
	case (SynchronizationAction.synchronize, .authenticated): return synchronize(currentState: currentState)
	case (SynchronizationAction.deleteUser, .authenticated): return deleteUser(currentState: currentState)
	case (SynchronizationAction.completeTask(let uuid), .authenticated): return updateTaskCompletionStatus(currentState: currentState, taskUuid: uuid)
	case (SynchronizationAction.updateConfiguration, _): return updateConfiguration(currentState: currentState)
	case (SynchronizationAction.deleteCache, .authenticated): return deleteCache(currentState: currentState)
	case (SynchronizationAction.updateHost(let newHost), _): return updateHost(currentState: currentState, newHost: newHost)
	default: return .empty()
	}
}

fileprivate func deleteUser(currentState state: AppState) -> Observable<RxStateMutator<AppState>> {
	guard let info = state.authentication.info else { return .empty() }
	
	return state.webService.deleteUser(tokenHeader: info.tokenHeader)
		.flatMap { Observable.just( { $0 } ) }
}

fileprivate func deleteCache(currentState state: AppState) -> Observable<RxStateMutator<AppState>> {
	guard let info = state.authentication.info else { return .empty() }
	
	let mainRealmFile = FileManager.default.realmsDirectory.appendingPathComponent("\(info.uid).realm")
	let allRealmFiles = [
		mainRealmFile,
		mainRealmFile.appendingPathExtension("lock"),
		mainRealmFile.appendingPathExtension("note"),
		mainRealmFile.appendingPathExtension("management")
	]
	
	allRealmFiles.forEach { try? FileManager.default.removeItem(at: $0) }
	
	return .just( { $0 } )
}
fileprivate func updateHost(currentState state: AppState, newHost: String) -> Observable<RxStateMutator<AppState>> {
	let newWebService = state.webService.withNew(host: newHost)
	return .just( { $0.mutation.new(webService: newWebService) } )
}


fileprivate func updateConfiguration(currentState state: AppState) -> Observable<RxStateMutator<AppState>> {
	guard let info = state.authentication.info else {
		let newRepository = state.repository.withNew(realmConfiguration: Realm.Configuration())
		return .just( { $0.mutation.new(repository: newRepository) } )
	}

	let newConfig = Realm.Configuration(withFileName: info.uid)
	
	let newRepository = state.repository.withNew(realmConfiguration: newConfig)
	return .just( { $0.mutation.new(repository: newRepository) } )
}

fileprivate func update(task: Task, currentState state: AppState) -> Observable<RxStateMutator<AppState>> {
	_ = try? state.repository.addOrUpdate(task: task)
	return .just( { $0 } )
}

fileprivate func add(task: Task, currentState state: AppState) -> Observable<RxStateMutator<AppState>> {
	_ = try? state.repository.addOrUpdate(task: task)
	return .just( { $0 } )
}

fileprivate func synchronize(currentState state: AppState) -> Observable<RxStateMutator<AppState>> {
	guard let info = state.authentication.info else { return .empty() }
	
	return Observable.create { observer in
		observer.onNext( { $0.mutation.new(syncStatus: .inProgress) })
		
		let subscription = synchronize(authenticationInfo: info, repository: state.repository, webService: state.webService)
			.do(onError: { error in
				observer.onNext( { $0.mutation.new(syncStatus: .failed(error)) } )
				if error.isNotConnectedToInternet() || error.isCannotConnectToHost() || error.isTimedOut() || error.isInvalidResponse() {
					observer.onError(error)
				}
			},
			    onCompleted: {observer.onNext( { $0.mutation.new(syncStatus: .completed) }) },
			    onDispose: { observer.onCompleted() })
			.subscribe()
		
		return Disposables.create {
			subscription.dispose()
		}
	}
}

fileprivate func synchronize(authenticationInfo: AuthenticationInfo, repository: RepositoryType, webService: WebServiceType) -> Observable<Void> {
	var toCreate = [Task]()
	var toUpdate = [Task]()
	var toDelete = [UniqueIdentifier]()
	
	repository.modifiedTasks().forEach {
		switch $0.synchronizationStatus {
		case .created: toCreate.append($0.toStruct())
		case .modified: toUpdate.append($0.toStruct())
		case .deleted: toDelete.append(UniqueIdentifier(identifierString: $0.uuid)!)
		default: break
		}
	}
	
	return webService.update(with: BatchUpdate(toCreate: toCreate, toUpdate: toUpdate, toDelete: toDelete), tokenHeader: authenticationInfo.tokenHeader)
		.flatMapLatest { result -> Observable<Void> in
			try? repository.removeAllTasks()
			_ = try? repository.import(tasks: result)
			return .empty()
	}
}


fileprivate func deleteTask(by uuid: UniqueIdentifier, currentState state: AppState) -> Observable<RxStateMutator<AppState>> {
	_ = try? state.repository.markDeleted(taskUuid: uuid.uuid)
	return .just( { $0 } )
}

fileprivate func updateTaskCompletionStatus(currentState state: AppState, taskUuid: UniqueIdentifier) -> Observable<RxStateMutator<AppState>> {
	_ = try? state.repository.complete(taskUuid: taskUuid.uuid)
	return .just({ $0 })
}
