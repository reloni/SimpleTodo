//
//  SynchronizationService.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 09.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

protocol SynchronizationServiceType {
	var repository: RepositoryType { get }
	var webService: WebServiceType { get }
	
	func overdueTasksCount() -> Int
	func tasks() -> Results<RealmTask>
	func task(for index: Int) -> RealmTask
	func delete(taskUuid uuid: UUID)
	func complete(taskUuid uuid: UUID)
	func addOrUpdate(task: Task)
	func synchronize(authenticationInfo: AuthenticationInfo) -> Observable<Void>
	func deleteUser(authenticationInfo: AuthenticationInfo) -> Observable<Void>
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
		return repository.tasks().sorted(byKeyPath: "targetDate", ascending: true)
	}
	
	func addOrUpdate(task: Task) {
		_ = try? repository.addOrUpdate(task: task)
	}
	
	func delete(taskUuid uuid: UUID) {
		try? repository.markDeleted(taskUuid: uuid)
	}
	
	func complete(taskUuid uuid: UUID) {
		_ = try? repository.complete(taskUuid: uuid)
	}
	
	func deleteUser(authenticationInfo: AuthenticationInfo) -> Observable<Void> {
		return webService.deleteUser(tokenHeader: .just(authenticationInfo.tokenHeader))
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
