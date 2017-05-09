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
}

protocol RepositoryType {
	func overdueTasksCount() -> Int
	func tasks() -> Results<RealmTask>
	func task(for uuid: UUID) -> RealmTask?
	func task(for index: Int) -> RealmTask
	func delete(task: Task) throws
	func addOrUpdate(task: Task) throws -> RealmTask
	func modifiedTasks() -> Results<RealmTask>
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
		return realm.objects(RealmTask.self).filter("_synchronizationStatus == %@", ObjectSynchronizationStatus.modified)
	}
	
	func task(for uuid: UUID) -> RealmTask? {
		return realm.object(ofType: RealmTask.self, forPrimaryKey: uuid.uuidString)
	}
	
	func task(for index: Int) -> RealmTask {
		return tasks()[index]
	}
	
	func markDeleted(task: Task) throws {
		guard let object = self.task(for: task.uuid.uuid) else { return }
		try realm.write {
			object.synchronizationStatus = .deleted
		}
	}
	
	func delete(task: Task) throws {
		guard let object = self.task(for: task.uuid.uuid) else { return }
		try realm.write {
			realm.delete(object)
		}
	}
	
	func addOrUpdate(task: Task) throws -> RealmTask {
		return try addOrUpdate(task: task, createStatus: .created, updateStatus: .modified)
	}
	
	func `import`(task: Task) throws -> RealmTask {
		return try addOrUpdate(task: task, createStatus: .unchanged, updateStatus: .unchanged)
	}
	
	func addOrUpdate(task: Task, createStatus: ObjectSynchronizationStatus, updateStatus: ObjectSynchronizationStatus) throws -> RealmTask {
		guard let t = self.task(for: task.uuid.uuid) else { return try self.create(new: task, withSyncStatus: createStatus) }
		return try self.update(existing: t, with: task, withSyncStatus: updateStatus)
	}
	
	private func update(existing object: RealmTask, with task: Task, withSyncStatus syncStatus: ObjectSynchronizationStatus) throws -> RealmTask {
		try realm.write {
			object.completed = task.completed
			object.notes = task.notes
			object.targetDate = task.targetDate?.date
			object.targetDateIncludeTime = task.targetDate?.includeTime ?? false
			object.taskDescription = task.description
			object.synchronizationStatus = syncStatus
		}
		
		return object
	}
	
	private func create(new task: Task, withSyncStatus syncStatus: ObjectSynchronizationStatus) throws -> RealmTask {
		let object = RealmTask()
		
		object.uuid = task.uuid.uuid.uuidString
		object.completed = task.completed
		object.notes = task.notes
		object.targetDate = task.targetDate?.date
		object.targetDateIncludeTime = task.targetDate?.includeTime ?? false
		object.taskDescription = task.description
		object.synchronizationStatus = syncStatus
		
		try realm.write {
			realm.add(object)
		}
		
		return object
	}
}
