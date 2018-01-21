//
//  TableSections.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 31.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import RxDataSources

typealias TasksControllerConfigureCell = (TableViewSectionedDataSource<TaskSection>, UITableView, IndexPath, TaskSection.Item) -> UITableViewCell

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
	case email(title: String, image: UIImage)
	case iconBadgeStyle(title: String, value: String, image: UIImage?)
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

struct TaskRepeatModeSection {
	let header: String
	var items: [Item]
}

extension TaskRepeatModeSection: SectionModelType {
	typealias Item = TaskRepeatModeSectionItem
	
	init(original: TaskRepeatModeSection, items: [TaskRepeatModeSectionItem]) {
		self = original
		self.items = items
	}
}

struct TaskRepeatModeSectionItem {
	let text: String
	let isSelected: Bool
	let mode: TaskScheduler.Pattern?
	let isCustom: Bool
}

struct CustomTaskRepeatModeSection {
	let header: String
	var items: [Item]
}

extension CustomTaskRepeatModeSection: SectionModelType {
	typealias Item = CustomTaskRepeatModeSectionItem
	
	init(original: CustomTaskRepeatModeSection, items: [CustomTaskRepeatModeSectionItem]) {
		self = original
		self.items = items
	}
}

enum CustomTaskRepeatModeSectionItem {
	enum PatternType: String {
		case day = "Daily"
		case week = "Weekly"
		case month = "Monthly"
		case year = "Yearly"
	}
	case patternType(PatternType)
	case repeatEvery(Int)
	
	var mainText: String {
		switch self {
		case .patternType: return "Frequency"
		case .repeatEvery: return "Every"
		}
	}
	
	var detailText: String {
		switch self {
		case .patternType(let p): return p.rawValue
		case .repeatEvery(let v): return "\(v)"
		}
	}
}
