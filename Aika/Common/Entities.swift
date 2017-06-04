//
//  Entities.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 17.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Unbox
import RxDataSources
import RxSwift
import Wrap
import OneSignal
import UserNotificationsUI

enum AuthenticationError : Error {
	case signInError(Error)
	case registerError(Error)
	case tokenRequestError(Error)
	case unknown
	case passwordResetError(Error)
	case notAuthorized
}

struct ServerSideError {
	let error: String
}

extension ServerSideError : Unboxable {
	init(unboxer: Unboxer) throws {
		self.error = try unboxer.unbox(key: "Error")
	}
}

struct UserSettings {
	var pushNotificationsAllowed: Observable<Bool> {
		return Observable.create { observer in
			UNUserNotificationCenter.current().getNotificationSettings {
				observer.onNext($0.alertSetting.rawValue == 2)
				observer.onCompleted()
			}
			
			return Disposables.create()
		}
	}
	var pushNotificationsEnabled: Bool { return OneSignal.getPermissionSubscriptionState().subscriptionStatus.subscribed }
}

struct UniqueIdentifier: UnboxableByTransform {
	typealias UnboxRawValue = String
	
	let uuid: UUID
	
	init?(identifierString: String) {
		if let id = UUID(uuidString: identifierString) {
			self.uuid = id
		} else {
			return nil
		}
	}
	
	init() {
		uuid = UUID()
	}
	
	static func transform(unboxedValue: String) -> UniqueIdentifier? {
		return UniqueIdentifier(identifierString: unboxedValue)
	}
}

extension UniqueIdentifier : Equatable {
	static func == (lhs: UniqueIdentifier, rhs: UniqueIdentifier) -> Bool {
		return lhs.uuid.uuidString == rhs.uuid.uuidString
	}
}

extension UniqueIdentifier : Hashable {
	var hashValue: Int { return uuid.hashValue }
}

extension UniqueIdentifier : CustomStringConvertible {
	var description: String { return uuid.uuidString }
}

extension UniqueIdentifier : WrapCustomizable {
	func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
		return uuid.uuidString
	}
}

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

struct TaskUser {
	let id: UInt64
	let firstName: String
	let lastName: String
	let emai: String
	let password: String
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

struct BatchUpdate {
	let toCreate: [Task]
	let toUpdate: [Task]
	let toDelete: [UniqueIdentifier]
}

extension BatchUpdate: WrapCustomizable {
	func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
		var dict = [String: Any]()
		
		dict["toCreate"] = toCreate.map { $0.wrap(context: context, dateFormatter: dateFormatter) }
		dict["toUpdate"] = toUpdate.map { $0.wrap(context: context, dateFormatter: dateFormatter) }
		dict["toDelete"] = toDelete.map { $0.wrap(context: context, dateFormatter: dateFormatter) }
		
		return dict
	}
}
