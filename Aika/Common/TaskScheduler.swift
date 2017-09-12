//
//  TaskScheduler.swift
//  Aika
//
//  Created by Anton Efimenko on 01.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import Wrap
import Unbox

struct TaskScheduler {
	enum Pattern {
		case daily
		case weekly
		case biweekly
		case monthly
		case yearly
		case byDay(repeatEvery: UInt)
		case byWeek(repeatEvery: UInt, weekDays: [DayOfWeek])
		case byMonthDays(repeatEvery: UInt, days: [UInt])
	}
	
    enum DayOfWeek: Int {
		case sunday = 1
		case monday = 2
		case tuesday = 3
		case wednesday = 4
		case thursday = 5
		case friday = 6
		case saturday = 7
	}
	
	let currentDate: Date
	
	public init() {
		self.init(currentDate: Date())
	}
	
	init(currentDate: Date) {
		self.currentDate = currentDate
	}
	
	var calendar: Calendar { return Calendar.current }
    
    func dateComponents(for date: Date) -> DateComponents {
        return calendar.dateComponents([.hour, .minute, .second], from: date)
    }
    
    var currentDayOfWeek: Int? {
        return calendar.dateComponents([.weekday], from: currentDate).weekday
    }
    
    var currentDayOfMonth: Int? {
        return calendar.dateComponents([.day], from: currentDate).day
    }
	
	func scheduleNext(from time: Date, withPattern pattern: Pattern) -> Date? {
		switch pattern {
        case .daily: return nextTime(for: time)
        case .weekly: return nextTime(for: time.adding(.day, value: 6))
        case .biweekly: return nextTime(for: time.adding(.day, value: 13))
        case .monthly: return nextTime(for: time.adding(.month, value: 1).adding(.day, value: -1))
        case .yearly: return nextTime(for: time.adding(.year, value: 1).adding(.day, value: -1))
        case .byDay(let repeatEvery): return nextTime(for: time.adding(.day, value: Int(repeatEvery) - 1))
        case let .byWeek(repeatEvery, weekDays):
			return nextTimeByWeek(for: time, repeatEvery: Int(repeatEvery), weekDays: weekDays.sorted(by: { $0.0.rawValue < $0.1.rawValue }))
        case let .byMonthDays(repeatEvery, days):
            return nextTimeByMonthDays(for: time, repeatEvery: Int(repeatEvery), days: days.map { Int($0) }.sorted(by: <))
		}
	}
    
    func nextTime(for value: Date) -> Date? {
        let components = dateComponents(for: value)

        let matchingComponents = DateComponents(calendar: calendar, hour: components.hour, minute: components.minute, second: components.second)

        return calendar.nextDate(after: value,
                                 matching: matchingComponents,
                                 matchingPolicy: .nextTimePreservingSmallerComponents,
                                 repeatedTimePolicy: .first,
                                 direction: .forward)
    }
    
    func nextTimeByWeek(for value: Date, repeatEvery: Int, weekDays: [DayOfWeek]) -> Date? {
		guard weekDays.count > 0 else {
			return nextTime(for: value.adding(.day, value: Int(repeatEvery * 7) - 1))
		}
		
		guard let currentDayOfWeek = currentDayOfWeek else { return nextTime(for: value.adding(.day, value: Int(repeatEvery * 7) - 1)) }
		
        let nextDayOfWeek = weekDays.first(where: { $0.rawValue > currentDayOfWeek })//.filter({ $0.rawValue > currentDayOfWeek }).first
        
        let components = dateComponents(for: value)
		
		let matchingComponents = DateComponents(calendar: calendar,
		                                        hour: components.hour,
		                                        minute: components.minute,
		                                        second: components.second,
		                                        weekday: nextDayOfWeek?.rawValue ?? weekDays.first?.rawValue)

		
		return calendar.nextDate(after: nextDayOfWeek != nil ? value : value.adding(.day, value: (repeatEvery * 7) - 1),
		                         matching: matchingComponents,
		                         matchingPolicy: .nextTimePreservingSmallerComponents,
		                         repeatedTimePolicy: .first,
		                         direction: .forward)
    }
    
    func nextTimeByMonthDays(for value: Date, repeatEvery: Int, days: [Int]) -> Date? {
        guard days.count > 0 else {
            return nextTime(for: value.adding(.month, value: Int(repeatEvery)).adding(.day, value: -1))
        }
        
        guard let currentDayOfMonth = currentDayOfMonth else {
            return nextTime(for: value.adding(.month, value: Int(repeatEvery)).adding(.day, value: -1))
        }
        
        let nextDayOfMonth = days.first(where: { $0 > currentDayOfMonth })
        
        let components = dateComponents(for: value)
        
        let matchingComponents = DateComponents(calendar: calendar,
                                                day: nextDayOfMonth ?? days.first,
                                                hour: components.hour,
                                                minute: components.minute,
                                                second: components.second)
        
        return calendar.nextDate(after: nextDayOfMonth != nil ? value : value.adding(.month, value: repeatEvery).beginningOfMonth(),
                                 matching: matchingComponents,
                                 matchingPolicy: .nextTimePreservingSmallerComponents,
                                 repeatedTimePolicy: .first,
                                 direction: .forward)
    }
}

extension TaskScheduler.Pattern: Equatable {
	public static func ==(lhs: TaskScheduler.Pattern, rhs: TaskScheduler.Pattern) -> Bool {
		switch (lhs, rhs) {
		case (TaskScheduler.Pattern.daily, TaskScheduler.Pattern.daily): return true
		case (TaskScheduler.Pattern.weekly, TaskScheduler.Pattern.weekly): return true
		case (TaskScheduler.Pattern.biweekly, TaskScheduler.Pattern.biweekly): return true
		case (TaskScheduler.Pattern.monthly, TaskScheduler.Pattern.monthly): return true
		case (TaskScheduler.Pattern.yearly, TaskScheduler.Pattern.yearly): return true
		case (TaskScheduler.Pattern.byDay(let l), TaskScheduler.Pattern.byDay(let r)): return l == r
		case (TaskScheduler.Pattern.byMonthDays(let lRepeat, let lDays), TaskScheduler.Pattern.byMonthDays(let rRepeat, let rDays)):
			return lRepeat == rRepeat && lDays == rDays
		case (TaskScheduler.Pattern.byWeek(let lRepeat, let lWeekDays), TaskScheduler.Pattern.byWeek(let rRepeat, let rWeekDays)):
			return lRepeat == rRepeat && lWeekDays == rWeekDays
		default: return false
		}
	}
	
	func toJson() -> [String: Any] {
		switch self {
		case .daily: return ["type": "daily"]
		case .weekly: return ["type": "weekly"]
		case .biweekly: return ["type": "biweekly"]
		case .monthly: return ["type": "monthly"]
		case .yearly: return ["type": "yearly"]
		case .byDay(let repeatEvery): return ["type": "byDay", "repeatEvery": "\(repeatEvery)"]
		case let .byWeek(repeatEvery, weekDays):
			return ["type": "byWeek", "repeatEvery": "\(repeatEvery)", "weekDays": weekDays.map { $0.rawValue }]
		case let .byMonthDays(repeatEvery, days):
			return ["type": "byMonthDays", "repeatEvery": "\(repeatEvery)", "days": days]
		}
	}
}

extension TaskScheduler.Pattern {
	static func parse(fromJson string: String) -> TaskScheduler.Pattern? {
		guard let data = string.data(using: .utf8) else { return nil }
		guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
		guard let dictionary = json as? [String : Any] else { return nil }
		
		switch dictionary["type"] as? String {
		case let type where type == "daily": return .daily
		case let type where type == "weekly": return .weekly
		case let type where type == "biweekly": return .biweekly
		case let type where type == "monthly": return .monthly
		case let type where type == "yearly": return .yearly
		case let type where type == "byDay":
			guard let repeatEvery = dictionary.toUint("repeatEvery") else { return nil }
			return .byDay(repeatEvery: repeatEvery)
		case let type where type == "byWeek":
			guard let weekDays = (dictionary["weekDays"] as? [Int])?.flatMap({ TaskScheduler.DayOfWeek.init(rawValue: $0) }), weekDays.count > 0 else { return nil }
			guard let repeatEvery = dictionary.toUint("repeatEvery") else { return nil }
			return .byWeek(repeatEvery: repeatEvery, weekDays: weekDays)
		case let type where type == "byMonthDays":
			guard let days = (dictionary["days"] as? [UInt])?.filter({ 0...31 ~= $0 }).distinct().sorted(), days.count > 0 else { return nil }
			guard let repeatEvery = dictionary.toUint("repeatEvery") else { return nil }
			return .byMonthDays(repeatEvery: repeatEvery, days: days)
		default: return nil
		}
	}
}

extension TaskScheduler.Pattern: WrapCustomizable {
    func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
		return toJson()
    }
}
