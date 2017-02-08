//
//  Entities.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 17.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Unbox
import RxDataSources
import Wrap

struct ServerSideError {
	let error: String
}

extension ServerSideError : Unboxable {
	init(unboxer: Unboxer) throws {
		self.error = try unboxer.unbox(key: "Error")
	}
}

struct LogInInfo {
	let email: String
	let password: String
	
	func toBasicAuthKey() -> String {
		return "Basic " + "\(email):\(password)".data(using: String.Encoding.utf8)!.base64EncodedString(options: [])
	}
}

struct UniqueIdentifier: UnboxableByTransform {
	typealias UnboxRawValue = String
	
	let identifierString: String
	
	init?(identifierString: String) {
		if let UUID = UUID(uuidString: identifierString) {
			self.identifierString = UUID.uuidString
		} else {
			return nil
		}
	}
	
	static func transform(unboxedValue: String) -> UniqueIdentifier? {
		return UniqueIdentifier(identifierString: unboxedValue)
	}
}

extension UniqueIdentifier : Equatable {
	static func == (lhs: UniqueIdentifier, rhs: UniqueIdentifier) -> Bool {
		return lhs.identifierString == rhs.identifierString
	}
}

extension UniqueIdentifier : Hashable {
	var hashValue: Int { return identifierString.hashValue }
}

extension UniqueIdentifier : CustomStringConvertible {
	var description: String { return identifierString }
}

extension UniqueIdentifier : WrapCustomizable {
	func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
		return identifierString
	}
}

struct ToDoEntry {
	let uuid: UniqueIdentifier
	let completed: Bool
	let description: String
	let notes: String?
}

extension ToDoEntry : Equatable {
	static func == (lhs: ToDoEntry, rhs: ToDoEntry) -> Bool {
		return lhs.uuid == rhs.uuid
			&& lhs.completed == rhs.completed
			&& lhs.description == rhs.description
			&& lhs.notes == rhs.notes
	}
}

extension ToDoEntry : IdentifiableType {
	var identity: UniqueIdentifier { return uuid }
}

struct ToDoUser {
	let id: UInt64
	let firstName: String
	let lastName: String
	let emai: String
	let password: String
}

extension ToDoEntry: Unboxable {
	init(unboxer: Unboxer) throws {
		self.uuid = try unboxer.unbox(key: "uuid")
		self.completed = try unboxer.unbox(key: "completed")
		self.description = try unboxer.unbox(key: "description")
		self.notes = unboxer.unbox(key: "notes")
	}
}
