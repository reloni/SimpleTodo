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
	case tokenRequestError(Error)
    case unknown
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
}

extension Task : Equatable {
	static func == (lhs: Task, rhs: Task) -> Bool {
		return lhs.uuid == rhs.uuid
			&& lhs.completed == rhs.completed
			&& lhs.description == rhs.description
			&& lhs.notes == rhs.notes
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
	}
}
