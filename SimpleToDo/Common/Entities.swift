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

enum ApplicationError : Error {
    case notAuthenticated
}

enum FirebaseError : Error {
	case signInError(Error)
	case registerError(Error)
	case tokenRequestError(Error)
	case unknown
	case passwordResetError(Error)
}

struct ServerSideError {
	let error: String
}

extension ServerSideError : Unboxable {
	init(unboxer: Unboxer) throws {
		self.error = try unboxer.unbox(key: "Error")
	}
}

protocol LoginUser {
    var token: Observable<String> { get }
}

extension LoginUser {
	var tokenHeader: Observable<String> {
		return token.flatMap { token -> Observable<String> in return .just("Bearer \(token)") }
	}
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
}

struct TaskDate {
	let date: Date
	let includeTime: Bool
}

extension TaskDate : Equatable {
	public static func ==(lhs: TaskDate, rhs: TaskDate) -> Bool {
		return lhs.date == rhs.date && lhs.includeTime && rhs.includeTime
	}
}

extension Task : Equatable {
	static func == (lhs: Task, rhs: Task) -> Bool {
		return lhs.uuid == rhs.uuid
			&& lhs.completed == rhs.completed
			&& lhs.description == rhs.description
			&& lhs.notes == rhs.notes
			&& lhs.targetDate == rhs.targetDate
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
		dict["targetDate"] = targetDate?.date.serverDate ?? NSNull()
		dict["targetDateIncludeTime"] = targetDate?.includeTime ?? NSNull()
		
		return dict
	}
	
}
