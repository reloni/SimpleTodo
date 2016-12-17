//
//  Entities.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 17.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Unbox
import RxDataSources

struct ToDoEntry {
	let id: UInt64
	let completed: Bool
	let description: String
	let notes: String?
}

extension ToDoEntry : Equatable {
	static func == (lhs: ToDoEntry, rhs: ToDoEntry) -> Bool {
		return lhs.id == rhs.id
	}
}

extension ToDoEntry : IdentifiableType {
	var identity: UInt64 { return id }
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
		self.id = try unboxer.unbox(key: "id")
		self.completed = try unboxer.unbox(key: "completed")
		self.description = try unboxer.unbox(key: "description")
		self.notes = unboxer.unbox(key: "notes")
	}
}
