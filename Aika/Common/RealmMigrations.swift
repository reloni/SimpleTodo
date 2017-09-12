//
//  RealmMigrations.swift
//  Aika
//
//  Created by Anton Efimenko on 10.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm.Configuration {
	init(withFileName fileName: String) {
		self.init(schemaVersion: 1, migrationBlock: { Realm.migrate(migration: $0, oldSchemaVersion: $1) })
		fileURL = FileManager.default.realmsDirectory.appendingPathComponent("\(fileName).realm")
		objectTypes = [RealmTask.self, RealmTaskPrototype.self]
	}
}

extension Realm {
	static func migrate(migration: Migration, oldSchemaVersion: UInt64) {
		if oldSchemaVersion < 1 {
			migrateToV1(migration: migration)
		}
	}
	
	static func migrateToV1(migration: Migration) {
		migration.deleteData(forType: RealmTask.className())
	}
}
