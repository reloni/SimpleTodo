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

extension TaskRepeatModeSection: AnimatableSectionModelType {
	typealias Item = TaskRepeatModeSectionItem
    
    var identity: String {
        return header
    }
	
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
    let isSubtitle: Bool
    init(text: String, isSelected: Bool, mode: TaskScheduler.Pattern?, isCustom: Bool, isSubtitle: Bool = false) {
        self.text = text
        self.isSelected = isSelected
        self.mode = mode
        self.isCustom = isCustom
        self.isSubtitle = isSubtitle
    }
}

extension TaskRepeatModeSectionItem: Equatable, IdentifiableType {
    static func ==(lhs: TaskRepeatModeSectionItem, rhs: TaskRepeatModeSectionItem) -> Bool {
        return lhs.text == rhs.text && lhs.isSelected == rhs.isSelected
    }
    
    var identity: String {
        return isSubtitle ? "Subtitle" : text
    }
}

struct CustomTaskRepeatModeSection {
	let header: String
	var items: [Item]
}

extension CustomTaskRepeatModeSection: AnimatableSectionModelType {
	typealias Item = CustomTaskRepeatModeSectionItem
    
    var identity: String {
        return header
    }
	
	init(original: CustomTaskRepeatModeSection, items: [CustomTaskRepeatModeSectionItem]) {
		self = original
		self.items = items
	}
}

enum CustomTaskRepeatModeSectionItem {
    case placeholder(id: String)
    case patternType(pattern: CustomRepeatPatternType)
    case weekday(name: String, value: TaskScheduler.DayOfWeek, isSelected: Bool)
    case monthDays(name: String)
    case patternTypePicker
    case repeatEvery(value: Int)
    case repeatEveryPicker
	
	var mainText: String {
		switch self {
		case .patternType: return "Frequency"
		case .repeatEvery: return "Every"
        default: return ""
		}
	}
	
	var detailText: String {
		switch self {
		case .patternType(let p): return p.rawValue
		case .repeatEvery(let v): return "\(v)"
        default: return ""
		}
	}
}

extension CustomTaskRepeatModeSectionItem: Equatable, IdentifiableType {
    static func ==(lhs: CustomTaskRepeatModeSectionItem, rhs: CustomTaskRepeatModeSectionItem) -> Bool {
        switch(lhs, rhs) {
        case (.patternType(let l), .patternType(let r)): return l.rawValue == r.rawValue
        case (.repeatEvery(let l), .repeatEvery(let r)): return l == r
        case (.placeholder(let l), .placeholder(let r)): return l == r
        case (patternTypePicker, patternTypePicker): return true
        case (repeatEveryPicker, repeatEveryPicker): return true
        case (.weekday(let l), .weekday(let r)): return l.name == r.name && l.value == r.value && l.isSelected == r.isSelected
        default: return false
        }
    }
    
    var identity: String {
        switch self {
        case .patternType: return "patternType"
        case .repeatEvery: return "repeatEvery"
        case .placeholder(let id): return id
        case .patternTypePicker: return "patternTypePicker"
        case .repeatEveryPicker: return "repeatEveryPicker"
        case .weekday(let value): return value.name
        case .monthDays(let value): return value
        }
    }
}
