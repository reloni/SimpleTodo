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

class RealmTaskPrototype: Object {
	@objc dynamic var uuid: String = ""
	@objc dynamic var repeatPattern: String? = nil
	
	convenience init(from prototype: TaskPrototype) {
		self.init()
		
		uuid = prototype.uuid.uuidString
		repeatPattern = (try? prototype.repeatPattern?.toJson().toJsonString()) ?? nil
	}
	
	func toStruct() -> TaskPrototype {
		return TaskPrototype(uuid: UUID(uuidString: uuid)!,
		                     repeatPattern: repeatPattern != nil ? TaskScheduler.Pattern.parse(fromJson: repeatPattern!) : nil)
	}
	
	func update(with prototype: TaskPrototype) {
		repeatPattern = (try? prototype.repeatPattern?.toJson().toJsonString()) ?? nil
	}
}

class RealmTask: Object {
	@objc dynamic var uuid: String = ""
	@objc dynamic var completed: Bool = false
	@objc dynamic var taskDescription: String = ""
	@objc dynamic var notes: String? = nil
	@objc dynamic var targetDate: Date? = nil
	@objc dynamic var targetDateIncludeTime: Bool = false
	@objc dynamic var _synchronizationStatus: String = ObjectSynchronizationStatus.created.rawValue
	@objc dynamic var prototype: RealmTaskPrototype!
	
	convenience init(from task: Task) {
		self.init()
		
		uuid = task.uuid.uuidString
		completed = task.completed
		notes = task.notes
		targetDate = task.targetDate?.date
		targetDateIncludeTime = task.targetDate?.includeTime ?? false
		taskDescription = task.description
		prototype = RealmTaskPrototype(from: task.prototype)
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
		return Task(uuid: UUID(uuidString: uuid)!,
		                                   completed: completed,
		                                   description: taskDescription,
		                                   notes: notes,
		                                   targetDate: taskDate,
		                                   prototype: prototype.toStruct())
	}
	
	func update(with task: Task) {
		completed = task.completed
		notes = task.notes
		targetDate = task.targetDate?.date
		targetDateIncludeTime = task.targetDate?.includeTime ?? false
		taskDescription = task.description
		prototype.update(with: task.prototype)
	}
}

protocol RepositoryType {
	func overdueTasksCount() -> Int
	func todayTasksCount() -> Int
	func allTasksCount() -> Int
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
	func markDeleted(taskUuid uuid: UUID) throws
	func complete(taskUuid uuid: UUID) throws -> RealmTask
	func withNew(realmConfiguration: Realm.Configuration) -> RepositoryType
}

final class RealmRepository: RepositoryType {
	var realm: Realm { return try! Realm(configuration: realmConfiguration) }
	let realmConfiguration: Realm.Configuration
	
	init(realmConfiguration: Realm.Configuration = Realm.Configuration.defaultConfiguration) {
		self.realmConfiguration = realmConfiguration
	}
	
	func withNew(realmConfiguration configuration: Realm.Configuration) -> RepositoryType {
		return RealmRepository(realmConfiguration: configuration)
	}
	
	func overdueTasksCount() -> Int {
		return realm.objects(RealmTask.self)
			.filter("targetDate < %@", Date())
			.filter("completed = false")
			.filter("_synchronizationStatus != %@", ObjectSynchronizationStatus.deleted.rawValue)
			.count
	}
	
	func allTasksCount() -> Int {
		return realm.objects(RealmTask.self).count
	}
	
	func todayTasksCount() -> Int {
		return realm.objects(RealmTask.self)
			.filter("targetDate >= %@ && targetDate <= %@", Date().beginningOfDay(), Date().endingOfDay())
			.count
	}
	
	func tasks() -> Results<RealmTask> {
		return realm
			.objects(RealmTask.self)
			.filter("completed == false")
			.filter("_synchronizationStatus != %@", ObjectSynchronizationStatus.deleted.rawValue)
			.sorted(byKeyPath: "targetDate", ascending: true)
	}
	
	func modifiedTasks() -> Results<RealmTask> {
		return realm.objects(RealmTask.self).filter("_synchronizationStatus != %@", ObjectSynchronizationStatus.unchanged.rawValue)
	}
	
	func removeAllTasks() throws {
		try realm.write {
			realm.delete(realm.objects(RealmTask.self))
			realm.delete(realm.objects(RealmTaskPrototype.self))
		}
	}
	
	func task(for uuid: UUID) -> RealmTask? {
		return realm.object(ofType: RealmTask.self, forPrimaryKey: uuid.uuidString)
	}
	
	func task(for index: Int) -> RealmTask {
		return tasks()[index]
	}
	
	func complete(taskUuid uuid: UUID) throws -> RealmTask {
		guard let object = task(for: uuid) else { fatalError("Unable to complete task with uuid = \(uuid.uuidString)") }
		
		let rlm = realm
		
		try rlm.write {
			object.completed = true
			object.synchronizationStatus = .modified
			
			let tmp = object.toStruct()
			
			if let date = tmp.targetDate?.date, let pattern = tmp.prototype.repeatPattern {
				let new = RealmTask(from: tmp)
				new.synchronizationStatus = .created
				new.uuid = UUID().uuidString
				new.completed = false
				new.targetDate = TaskScheduler().scheduleNext(from: date, withPattern: pattern)
				rlm.add(new)
			}
		}
		
		return object
	}
	
	func markDeleted(task: Task) throws {
		guard let object = self.task(for: task.uuid) else { return }
		try realm.write {
			object.synchronizationStatus = .deleted
		}
	}
	
	func markDeleted(taskUuid uuid: UUID) throws {
		guard let task = task(for: uuid) else { return }
		try realm.write {
			task.synchronizationStatus = .deleted
		}
	}
	
	func delete(task: Task) throws {
		guard let object = self.task(for: task.uuid) else { return }
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
		let rlm = realm
		var object: RealmTask!
		
		try rlm.write {
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
		guard let existed = self.task(for: task.uuid) else {
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
