//
//  TableSections.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 31.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import RxDataSources

struct TaskSection {
	var header: String
	var items: [Item]
}
extension TaskSection: AnimatableSectionModelType {
	typealias Item = Task
	
	var identity: String {
		return header
	}
	
	init(original: TaskSection, items: [Item]) {
		self = original
		self.items = items
	}
}

struct SettingsSection {
	var header: String
	var items: [SettingsSectonItem]
}

extension SettingsSection : SectionModelType {
	typealias Item = SettingsSectonItem
	
	init(original: SettingsSection, items: [SettingsSectonItem]) {
		self = original
		self.items = items
	}
}

enum SettingsSectonItem {
	case pushNotificationsSwitch(title: String, subtitle: String?, image: UIImage)
	case frameworks(title: String, image: UIImage)
	case sourceCode(title: String, image: UIImage)
	case deleteAccount(title: String, image: UIImage)
	case deleteLocalCache(title: String, image: UIImage)
	case exit(title: String, image: UIImage)
	case text(title: String, value: String, image: UIImage?)
}

struct FrameworksSection {
	var header: String
	var items: [Item]
}

struct FrameworkSectionItem {
	let name: String
	let url: URL
}

extension FrameworksSection: SectionModelType {
	typealias Item = FrameworkSectionItem
	
	var identity: String {
		return header
	}
	
	init(original: FrameworksSection, items: [Item]) {
		self = original
		self.items = items
	}
}
