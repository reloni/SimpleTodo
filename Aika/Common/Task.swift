//
//  Task.swift
//  Aika
//
//  Created by Anton Efimenko on 09.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import RxDataSources
import Unbox
import Wrap

struct Task {
	let uuid: UniqueIdentifier
	let completed: Bool
	let description: String
	let notes: String?
	let targetDate: TaskDate?
	let prototype: TaskPrototype
	
	// this field here for checking equality and to force UITableView to refresh
	// when app opens on next day (when relative dates like "today" should be changed)
	fileprivate let timestamp = Date().beginningOfDay()
}

struct TaskDate: Codable {
	let date: Date
	let includeTime: Bool
	let isFuture: Bool
	
	enum CodingKeys: String, CodingKey {
		case targetDate
		case targetDateIncludeTime
	}
	
	init(date: Date, includeTime: Bool) {
		self.includeTime = includeTime
		self.date = includeTime ? date.setting(.second, value: 0).setting(.nanosecond, value: 0) : date.beginningOfDay()
		self.isFuture = self.date.isInFuture
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		guard let targetDate = Date.fromServer(string: try container.decode(String.self, forKey: .targetDate)),
			let includeTime: Bool = try container.decode(Bool?.self, forKey: .targetDateIncludeTime) else {
			throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: [CodingKeys.targetDate, CodingKeys.targetDateIncludeTime], debugDescription: "Data not specified"))
		}
		
		self.init(date: targetDate, includeTime: includeTime)
	}
	
		func encode(to encoder: Encoder) throws {
	
		}
}

struct TaskPrototype {
	let uuid: UniqueIdentifier
	let repeatPattern: TaskScheduler.Pattern?
}

struct TaskPrototype2: Codable {
	enum CodingKeys: String, CodingKey {
		case uuid
		case repeatPattern = "cronExpression"
	}
	
	let uuid: UUID
	let repeatPattern: TaskScheduler.Pattern?
}

extension TaskPrototype2 {
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		uuid = try container.decode(UUID.self, forKey: .uuid)
		repeatPattern = (try? container.decodeIfPresent(TaskScheduler.Pattern.self, forKey: .repeatPattern)) ?? nil
	}
	
	func encode(to encoder: Encoder) throws {

	}
}

extension TaskPrototype: Unboxable {
	init(unboxer: Unboxer) throws {
		self.uuid = try unboxer.unbox(key: "uuid")
		if let cronExpression: String = unboxer.unbox(key: "cronExpression") {
			self.repeatPattern = TaskScheduler.Pattern.parse(fromJson: cronExpression)
		} else {
			self.repeatPattern = nil
		}
	}
}

extension TaskPrototype : WrapCustomizable {
	func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
		var dict = [String: Any]()
		
		dict["uuid"] = uuid.uuid.uuidString
		dict["cronExpression"] = (try? repeatPattern?.toJson().toJsonString() ?? "") ?? ""
		
		return dict
	}
}

extension TaskPrototype : Equatable {
	static func == (lhs: TaskPrototype, rhs: TaskPrototype) -> Bool {
		return lhs.uuid == rhs.uuid
			&& lhs.repeatPattern == rhs.repeatPattern
	}
}

extension TaskDate : Equatable {
	public static func ==(lhs: TaskDate, rhs: TaskDate) -> Bool {
		return lhs.date == rhs.date
			&& (lhs.includeTime == rhs.includeTime)
			&& lhs.isFuture == rhs.isFuture
	}
}

extension Task : Equatable {
	static func == (lhs: Task, rhs: Task) -> Bool {
		return lhs.uuid == rhs.uuid
			&& lhs.completed == rhs.completed
			&& lhs.description == rhs.description
			&& lhs.notes == rhs.notes
			&& lhs.targetDate == rhs.targetDate
			&& lhs.timestamp == rhs.timestamp
			&& lhs.prototype == rhs.prototype
	}
}

extension Task : IdentifiableType {
	var identity: UniqueIdentifier { return uuid }
}

extension Task: Unboxable {
	init(unboxer: Unboxer) throws {
		self.uuid = try unboxer.unbox(key: "uuid")
		self.completed = try unboxer.unbox(key: "completed")
		self.description = try unboxer.unbox(key: "description")
		self.notes = unboxer.unbox(key: "notes")
		if let date = Date.fromServer(string: unboxer.unbox(key: "targetDate") ?? ""),
			let includeTime: Bool = unboxer.unbox(key: "targetDateIncludeTime") {
			targetDate = TaskDate(date: date, includeTime: includeTime)
		} else {
			targetDate = nil
		}
		self.prototype = try unboxer.unbox(key: "prototype")
	}
}

extension Task : WrapCustomizable {
	func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
		var dict = [String: Any]()
		
		dict["uuid"] = uuid.uuid.uuidString
		dict["completed"] = completed
		dict["description"] = description
		dict["notes"] = notes ?? ""
		dict["targetDate"] = targetDate?.date.toServerDateString() ?? NSNull()
		dict["targetDateIncludeTime"] = targetDate?.includeTime ?? NSNull()
		dict["prototype"] = prototype.wrap(context: context, dateFormatter: dateFormatter)
		
		return dict
	}
}
