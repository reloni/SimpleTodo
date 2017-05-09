//
//  SynchronizationService.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 09.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RealmSwift

protocol SynchronizationServiceType {
	func overdueTasksCount() -> Int
	func tasks() -> Results<RealmTask>
	func task(for index: Int) -> RealmTask
	func delete(task: Task)
	func addOrUpdate(task: Task)
	var webService: WebServiceType { get }
}

final class SynchronizationService: SynchronizationServiceType {
	private let repository: RepositoryType
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
	
	func delete(task: Task) {
		try? repository.delete(task: task)
	}
}
