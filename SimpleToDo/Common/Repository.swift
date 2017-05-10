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
			_synchronizationStatus = newValue.rawValue
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
	func `import`(task: Task) throws -> RealmTask
	func `import`(tasks: [Task]) throws -> [RealmTask]
	func delete(taskIndex index: Int) throws
	func markDeleted(taskIndex index: Int) throws
	func complete(taskIndex index: Int) throws -> RealmTask
}

final class Repository: RepositoryType {
	var realm: Realm { return try! Realm() }
	
	func overdueTasksCount() -> Int {
		return realm.objects(RealmTask.self).filter("targetDate < %@ || targetDate = nil", Date()).count
	}
	
	func tasks() -> Results<RealmTask> {
		return realm.objects(RealmTask.self).filter("completed == false")
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
			object = addOrUpdate(task: task, createStatus: .created, updateStatus: .modified)
		}
		return object
	}
	
	func `import`(tasks: [Task]) throws -> [RealmTask] {
		var imported: [RealmTask]!
		try realm.write {
			imported = tasks.map { addOrUpdate(task: $0, createStatus: .unchanged, updateStatus: .unchanged) }
		}
		
		return imported
	}
	
	func `import`(task: Task) throws -> RealmTask {
		var object: RealmTask!
		try realm.write {
			object = addOrUpdate(task: task, createStatus: .unchanged, updateStatus: .unchanged)
		}
		return object
	}
	
	private func addOrUpdate(task: Task, createStatus: ObjectSynchronizationStatus, updateStatus: ObjectSynchronizationStatus) -> RealmTask {
		guard let existed = self.task(for: task.uuid.uuid) else {
			let new = RealmTask(from: task)
			new.synchronizationStatus = createStatus
			realm.add(new)
			return new
		}
		
		existed.update(with: task)
		existed.synchronizationStatus = updateStatus
		return existed
	}
}
