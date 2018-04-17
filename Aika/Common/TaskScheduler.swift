//
//  TaskScheduler.swift
//  Aika
//
//  Created by Anton Efimenko on 01.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation

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
	
		func numberInWeek(for calendar: Calendar) -> Int {
			let tmp = (rawValue - calendar.firstWeekday) + 1
			return tmp <= 0 ? tmp + 7 : tmp
		}
        
        var shortWeekdayPosix: String {
            return Calendar.gregorianPosix.shortWeekdaySymbols[rawValue - 1].capitalized
        }
	}
	
	var calendar: Calendar { return Calendar.current }
    
    func dateComponents(for date: Date, matching components: [Calendar.Component]) -> DateComponents {
        return calendar.dateComponents(Set(components), from: date)
    }
	
	func scheduleNext(from time: Date, withPattern pattern: Pattern) -> Date? {
		switch pattern {
        case .daily: return nextTime(for: time)
        case .weekly: return nextTime(for: time.adding(.day, value: 6, in: calendar), matchWeekday: time.weekday(in: calendar))
        case .biweekly: return nextTime(for: time.adding(.day, value: 13, in: calendar), matchWeekday: time.weekday(in: calendar))
        case .monthly: return nextTime(for: time.adding(.month, value: 1, in: calendar).adding(.day, value: -1, in: calendar), matchDay: time.dayOfMonth(in: calendar))
        case .yearly: return nextTime(for: time.adding(.year, value: 1, in: calendar).adding(.day, value: -1, in: calendar), matchDay: time.dayOfMonth(in: calendar), matchMonth: time.month(in: calendar))
        case .byDay(let repeatEvery): return nextTime(for: time.adding(.day, value: Int(repeatEvery) - 1, in: calendar))
        case let .byWeek(repeatEvery, weekDays):
			return nextTimeByWeek(for: time, repeatEvery: Int(repeatEvery), weekDays: weekDays.sorted(by: { $0.numberInWeek(for: calendar) < $1.numberInWeek(for: calendar) }))
        case let .byMonthDays(repeatEvery, days):
            return nextTimeByMonthDays(for: time, repeatEvery: Int(repeatEvery), days: days.map { Int($0) }.sorted(by: <))
		}
	}
    
    func nextTime(for value: Date, matchWeekday: Int? = nil, matchDay: Int? = nil, matchMonth: Int? = nil) -> Date? {
        let components = dateComponents(for: value, matching: [.hour, .minute, .second])
        
        let matchingComponents = DateComponents(calendar: calendar,
                                                month: matchMonth,
                                                day: matchDay,
                                                hour: components.hour,
                                                minute: components.minute,
                                                second: components.second,
                                                weekday: matchWeekday)
		let after = value < Date() ? Date() : value

        return calendar.nextDate(after: after,
                                 matching: matchingComponents,
                                 matchingPolicy: .strict,
                                 repeatedTimePolicy: .first,
                                 direction: .forward)
    }
    
    func nextTimeByWeek(for value: Date, repeatEvery: Int, weekDays: [DayOfWeek]) -> Date? {
		guard weekDays.count > 0 else {
			return nil
		}
		
		guard let weekday = value.weekday(in: calendar), let valueDayOfWeek = DayOfWeek(rawValue: weekday) else {
				return nil
		}

        let nextDayOfWeek = weekDays.first(where: { $0.numberInWeek(for: calendar) > valueDayOfWeek.numberInWeek(for: calendar) })
        
        let components = dateComponents(for: value, matching: [.hour, .minute, .second])
		
		let matchingComponents = DateComponents(calendar: calendar,
		                                        hour: components.hour,
		                                        minute: components.minute,
		                                        second: components.second,
		                                        weekday: nextDayOfWeek?.rawValue ?? weekDays.first?.rawValue)

		return calendar.nextDate(after: nextDayOfWeek != nil ? value : value.adding(.day, value: (repeatEvery - 1) * 7, in: calendar),
		                         matching: matchingComponents,
		                         matchingPolicy: .strict,
		                         repeatedTimePolicy: .first,
		                         direction: .forward)
    }
    
    func nextTimeByMonthDays(for value: Date, repeatEvery: Int, days: [Int]) -> Date? {
        guard days.count > 0 else {
            return nil
        }
        
        guard let dayOfMonth = value.dayOfMonth(in: calendar) else {
            return nil
        }
        
        let nextDayOfMonth = days.first(where: { $0 > dayOfMonth })
        
        let components = dateComponents(for: value, matching: [.hour, .minute, .second])
        
        let matchingComponents = DateComponents(calendar: calendar,
                                                day: nextDayOfMonth ?? days.first,
                                                hour: components.hour,
                                                minute: components.minute,
                                                second: components.second)
        
        return calendar.nextDate(after: nextDayOfMonth != nil ? value : value.adding(.month, value: repeatEvery, in: calendar).beginningOfMonth(in: calendar),
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
		case .byDay(let repeatEvery): return ["type": "byDay", "repeatEvery": Int(repeatEvery)]
		case let .byWeek(repeatEvery, weekDays):
			return ["type": "byWeek", "repeatEvery": Int(repeatEvery), "weekDays": weekDays.map { $0.rawValue }]
		case let .byMonthDays(repeatEvery, days):
			return ["type": "byMonthDays", "repeatEvery": Int(repeatEvery), "days": days]
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
			guard let weekDays = (dictionary["weekDays"] as? [Int])?.compactMap({ TaskScheduler.DayOfWeek.init(rawValue: $0) }), weekDays.count > 0 else { return nil }
			guard let repeatEvery = dictionary.toUint("repeatEvery") else { return nil }
			return .byWeek(repeatEvery: repeatEvery, weekDays: weekDays)
		case let type where type == "byMonthDays":
			guard let days = (dictionary["days"] as? [Int])?.filter({ 0...31 ~= $0 }).distinct().map(UInt.init).sorted(), days.count > 0 else { return nil }
			guard let repeatEvery = dictionary.toUint("repeatEvery") else { return nil }
			return .byMonthDays(repeatEvery: repeatEvery, days: days)
		default: return nil
		}
	}
}

extension TaskScheduler.Pattern: Codable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		guard let pattern = TaskScheduler.Pattern.parse(fromJson: try container.decode(String.self)) else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Wrong pattern")
		}
		self = pattern
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(try toJson().toJsonString())
	}
}
