//
//  SynchronizationService.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 09.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RealmSwift
import RxSwift

protocol SynchronizationServiceType {
	var repository: RepositoryType { get }
	var webService: WebServiceType { get }
	
	func overdueTasksCount() -> Int
	func tasks() -> Results<RealmTask>
	func task(for index: Int) -> RealmTask
	func delete(taskIndex index: Int)
	func complete(taskIndex index: Int)
	func addOrUpdate(task: Task)
	func synchronize(authenticationInfo: AuthenticationInfo) -> Observable<Void>
}

final class SynchronizationService: SynchronizationServiceType {
	let repository: RepositoryType
	let webService: WebServiceType

	init(webService: WebServiceType, repository: RepositoryType) {
		self.webService = webService
		self.repository = repository
	}
	
	func overdueTasksCount() -> Int {
		return repository.overdueTasksCount()
	}
	
	func task(for index: Int) -> RealmTask {
		return repository.task(for: index)
	}
	
	func tasks() -> Results<RealmTask> {
		return repository.tasks()
	}
	
	func addOrUpdate(task: Task) {
		_ = try? repository.addOrUpdate(task: task)
	}
	
	func delete(taskIndex index: Int) {
		try? repository.markDeleted(taskIndex: index)
	}
	
	func complete(taskIndex index: Int) {
		_ = try? repository.complete(taskIndex: index)
	}
	
	func synchronize(authenticationInfo: AuthenticationInfo) -> Observable<Void> {
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
		
		return webService.update(with: BatchUpdate(toCreate: toCreate, toUpdate: toUpdate, toDelete: toDelete), tokenHeader: .just(authenticationInfo.tokenHeader))
			.flatMapLatest { [weak self] result -> Observable<Void> in
				try? self?.repository.removeAllTasks()
				_ = try? self?.repository.import(tasks: result)
				return .empty()
			}
	}
}
