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
	
	// this field here for checking equality and to force UITableView to refresh
	// when app opens on next day (when relative dates like "today" should be changed)
	fileprivate let timestamp = Date().beginningOfDay()
}

struct TaskDate {
	let date: Date
	let includeTime: Bool
	let isFuture: Bool
	
	init(date: Date, includeTime: Bool) {
		self.includeTime = includeTime
		self.date = includeTime ? date.setting(.second, value: 0).setting(.nanosecond, value: 0) : date.beginningOfDay()
		self.isFuture = self.date.isInFuture
	}
	
	var underlineColor: UIColor? {
		switch date.type {
		case .todayPast: fallthrough
		case .past: fallthrough
		case .yesterday: return Theme.Colors.upsdelRed
		case .tomorrow: return Theme.Colors.pumkinLight
		default: return Theme.Colors.darkSpringGreen
		}
	}
	
	func toAttributedString(withSpelling: Bool) -> NSAttributedString {
		let str = NSMutableAttributedString(string: toString(withSpelling: withSpelling))
		
		let range = NSRange(location: 0, length: str.length)
		str.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
		if let underlineColor = underlineColor {
			str.addAttribute(NSUnderlineColorAttributeName, value: underlineColor, range: range)
		}
		
		return str
	}
	
	func toString(withSpelling: Bool) -> String {
		return includeTime ? date.toDateAndTimeString(withSpelling: withSpelling) : date.toDateString(withSpelling: withSpelling)
	}
}

struct TaskPrototype {
	let uuid: UniqueIdentifier
	let repeatPattern: TaskScheduler.Pattern?
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
		
		return dict
	}
}
