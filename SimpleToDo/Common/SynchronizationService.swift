//
//  SynchronizationService.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 09.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RealmSwift
import RxSwift

enum SynchronizationStatus {
	case completed
	case failed(Error)
	case inProgress
}

protocol SynchronizationServiceType {
//	var status: SynchronizationStatus { get }
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
	
//	var status = SynchronizationStatus.completed
	
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
	
	func synchronize() -> Observable<Void> {
//		status = .inProgress
		
		let scheduler = SerialDispatchQueueScheduler(qos: .utility)
		
		return Observable
			.from(repository.modifiedTasks().map { SynchronizationTask(task: $0) } + [SynchronizationTask(type: .fullSync)])
			.subscribeOn(scheduler)
			.flatMap { [weak self] syncTask -> Observable<[Task]> in
				guard let webService = self?.webService else { return .empty() }
				return SynchronizationService.sync(task: syncTask, webService: webService)
			}
			.flatMap { [weak self] tasks -> Observable<Void> in
				guard let repository = self?.repository else { return .empty() }
				tasks.forEach { _ = try? repository.addOrUpdate(task: $0) }; return .empty()
			}
	}
	
	private static func sync(task: SynchronizationTask, webService: WebServiceType) -> Observable<[Task]> {
		return .empty()
	}
}

struct SynchronizationTask {
	enum TaskType {
		case delete(Task)
		case update(Task)
		case create(Task)
		case skip
		case fullSync
	}
	
	let type: TaskType
	
	init(task: RealmTask) {
		type = {
			switch task.synchronizationStatus {
			case .created: return TaskType.create(task.toStruct())
			case ObjectSynchronizationStatus.deleted: return TaskType.delete(task.toStruct())
			case ObjectSynchronizationStatus.modified: return TaskType.update(task.toStruct())
			default: return TaskType.skip
			}
		}()
	}
	
	init(type: TaskType) {
		self.type = type
	}
}
