//
//  TableSections.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 31.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import RxDataSources

struct ToDoEntrySection {
	var header: String
	var items: [Item]
}
extension ToDoEntrySection: AnimatableSectionModelType {
	typealias Item = ToDoEntry
	
	var identity: String {
		return header
	}
	
	init(original: ToDoEntrySection, items: [Item]) {
		self = original
		self.items = items
	}
}
