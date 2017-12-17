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

struct Task: Codable {
	let uuid: UUID
	let completed: Bool
	let description: String
	let notes: String?
	let targetDate: TaskDate?
	let prototype: TaskPrototype
	
	enum CodingKeys: String, CodingKey {
		case uuid
		case completed
		case description
		case notes
		case prototype
		case targetDate
		case targetDateIncludeTime
	}
	
	// this field here for checking equality and to force UITableView to refresh
	// when app opens on next day (when relative dates like "today" should be changed)
	fileprivate let timestamp = Date().beginningOfDay()
	
	init(uuid: UUID, completed: Bool, description: String, notes: String?, targetDate: TaskDate?, prototype: TaskPrototype) {
		self.uuid = uuid
		self.completed = completed
		self.description = description
		self.notes = notes
		self.targetDate = targetDate
		self.prototype = prototype
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		uuid = try container.decode(UUID.self, forKey: .uuid)
		completed = try container.decode(Bool.self, forKey: .completed)
		description = try container.decode(String.self, forKey: .description)
		notes = try container.decodeIfPresent(String.self, forKey: .notes)
		targetDate = (try? decoder.singleValueContainer().decode(TaskDate.self)) ?? nil
		prototype = try container.decode(TaskPrototype.self, forKey: .prototype)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(uuid, forKey: .uuid)
		try container.encode(completed, forKey: .completed)
		try container.encode(description, forKey: .description)
		try container.encode(notes, forKey: .notes)
		try container.encode(targetDate?.date.toServerDateString(), forKey: .targetDate)
		try container.encode(targetDate?.includeTime, forKey: .targetDateIncludeTime)
		try container.encode(prototype, forKey: .prototype)
	}
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
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(includeTime, forKey: .targetDateIncludeTime)
		try container.encode(date.toServerDateString(), forKey: .targetDate)
	}
}

struct TaskPrototype: Codable {
	enum CodingKeys: String, CodingKey {
		case uuid
		case repeatPattern = "cronExpression"
	}
	
	let uuid: UUID
	let repeatPattern: TaskScheduler.Pattern?
	
	init(uuid: UUID, repeatPattern: TaskScheduler.Pattern?) {
		self.uuid = uuid
		self.repeatPattern = repeatPattern
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		uuid = try container.decode(UUID.self, forKey: .uuid)
		repeatPattern = (try? container.decodeIfPresent(TaskScheduler.Pattern.self, forKey: .repeatPattern)) ?? nil
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(uuid, forKey: .uuid)
		try container.encode(repeatPattern?.toJson().toJsonString(), forKey: .repeatPattern)
	}
}

extension TaskPrototype: Equatable {
	static func == (lhs: TaskPrototype, rhs: TaskPrototype) -> Bool {
		return lhs.uuid == rhs.uuid
			&& lhs.repeatPattern == rhs.repeatPattern
	}
}

extension TaskDate: Equatable {
	public static func ==(lhs: TaskDate, rhs: TaskDate) -> Bool {
		return lhs.date == rhs.date
			&& (lhs.includeTime == rhs.includeTime)
			&& lhs.isFuture == rhs.isFuture
	}
}

extension Task: Equatable {
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
	var identity: UUID { return uuid }
}
