//
//  Repository.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 09.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RealmSwift

enum ObjectSynchronizationStatus: String {
	case unchanged
	case created
	case modified
	case deleted
}

class RealmTask: Object {
	dynamic var uuid: String = ""
	dynamic var completed: Bool = false
	dynamic var taskDescription: String = ""
	dynamic var notes: String? = nil
	dynamic var targetDate: Date? = nil
	dynamic var targetDateIncludeTime: Bool = false
	dynamic var _synchronizationStatus: String = ObjectSynchronizationStatus.created.rawValue
	
	convenience init(from task: Task) {
		self.init()
		
		uuid = task.uuid.uuid.uuidString
		completed = task.completed
		notes = task.notes
		targetDate = task.targetDate?.date
		targetDateIncludeTime = task.targetDate?.includeTime ?? false
		taskDescription = task.description
	}
	
	var synchronizationStatus: ObjectSynchronizationStatus {
		get {
			return ObjectSynchronizationStatus(rawValue: _synchronizationStatus)!
		}
		set {
			set(syncStatus: newValue, force: false)
		}
	}
	
	func set(syncStatus: ObjectSynchronizationStatus, force: Bool) {
		guard !force else { _synchronizationStatus = syncStatus.rawValue; return }
		
		switch (current: self.synchronizationStatus, new: syncStatus) {
		case (.created, .deleted): fallthrough
		case (.unchanged, _): fallthrough
		case (.modified, .deleted): _synchronizationStatus = syncStatus.rawValue
		default: return
		}
	}
	
	var taskDate: TaskDate? {
		guard let targetDate = targetDate else { return nil }
		return TaskDate(date: targetDate, includeTime: targetDateIncludeTime)
	}
	
	override static func primaryKey() -> String? {
		return "uuid"
	}
	
	func toStruct() -> Task {
		return Task(uuid: UniqueIdentifier(identifierString: uuid)!,
		                                   completed: completed,
		                                   description: taskDescription,
		                                   notes: notes,
		                                   targetDate: taskDate)
	}
	
	func update(with task: Task) {
		completed = task.completed
		notes = task.notes
		targetDate = task.targetDate?.date
		targetDateIncludeTime = task.targetDate?.includeTime ?? false
		taskDescription = task.description
	}
}

protocol RepositoryType {
	func overdueTasksCount() -> Int
	func tasks() -> Results<RealmTask>
	func task(for uuid: UUID) -> RealmTask?
	func task(for index: Int) -> RealmTask
	func delete(task: Task) throws
	func addOrUpdate(task: Task) throws -> RealmTask
	func modifiedTasks() -> Results<RealmTask>
	func markDeleted(task: Task) throws
	func removeAllTasks() throws
	func `import`(tasks: [Task]) throws -> [RealmTask]
	func delete(taskIndex index: Int) throws
	func markDeleted(taskIndex index: Int) throws
	func complete(taskIndex index: Int) throws -> RealmTask
	func withNew(realmConfiguration: Realm.Configuration) -> RepositoryType
}

final class RealmRepository: RepositoryType {
	var realm: Realm { return try! Realm(configuration: realmConfiguration) }
	let realmConfiguration: Realm.Configuration
	
	init(realmConfiguration: Realm.Configuration = Realm.Configuration.defaultConfiguration) {
		self.realmConfiguration = realmConfiguration
	}
	
	func withNew(realmConfiguration: Realm.Configuration) -> RepositoryType {
		return RealmRepository(realmConfiguration: realmConfiguration)
	}
	
	func overdueTasksCount() -> Int {
		return realm.objects(RealmTask.self).filter("targetDate < %@ || targetDate = nil", Date()).count
	}
	
	func tasks() -> Results<RealmTask> {
		return realm.objects(RealmTask.self).filter("completed == false").filter("_synchronizationStatus != %@", ObjectSynchronizationStatus.deleted.rawValue)
	}
	
	func modifiedTasks() -> Results<RealmTask> {
		return realm.objects(RealmTask.self).filter("_synchronizationStatus != %@", ObjectSynchronizationStatus.unchanged.rawValue)
	}
	
	func removeAllTasks() throws {
		try realm.write {
			realm.delete(realm.objects(RealmTask.self))
		}
	}
	
	func task(for uuid: UUID) -> RealmTask? {
		return realm.object(ofType: RealmTask.self, forPrimaryKey: uuid.uuidString)
	}
	
	func task(for index: Int) -> RealmTask {
		return tasks()[index]
	}
	
	func complete(taskIndex index: Int) throws -> RealmTask {
		var object: RealmTask!
		
		try realm.write {
			object = tasks()[index]
			object.completed = true
			object.synchronizationStatus = .modified
		}
		
		return object
	}
	
	func markDeleted(task: Task) throws {
		guard let object = self.task(for: task.uuid.uuid) else { return }
		try realm.write {
			object.synchronizationStatus = .deleted
		}
	}
	
	func markDeleted(taskIndex index: Int) throws {
		try realm.write {
			tasks()[index].synchronizationStatus = .deleted
		}
	}
	
	func delete(task: Task) throws {
		guard let object = self.task(for: task.uuid.uuid) else { return }
		try realm.write {
			realm.delete(object)
		}
	}
	
	func delete(taskIndex index: Int) throws {
		try realm.write {
			realm.delete(tasks()[index])
		}
	}
	
	func addOrUpdate(task: Task) throws -> RealmTask {
		var object: RealmTask!
		try realm.write {
			object = addOrUpdateWithoutTransaction(task: task)
		}
		return object
	}
	
	func `import`(tasks: [Task]) throws -> [RealmTask] {
		var imported: [RealmTask]!
		try realm.write {
			imported = tasks.map {
				let object = addOrUpdateWithoutTransaction(task: $0)
				object.set(syncStatus: .unchanged, force: true)
				return object
			}
		}
		
		return imported
	}

	private func addOrUpdateWithoutTransaction(task: Task) -> RealmTask {
		guard let existed = self.task(for: task.uuid.uuid) else {
			let new = RealmTask(from: task)
			new.synchronizationStatus = .created
			realm.add(new)
			return new
		}
		
		existed.update(with: task)
		existed.synchronizationStatus = .modified
		return existed
	}
}
