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
//		case byYearMonths(repeatEvery: UInt, months: [Month])
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
	
	enum Month {
		case january
		case february
		case march
		case april
		case may
		case june
		case july
		case august
		case september
		case october
		case november
		case december
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
	
	func scheduleNext(from time: Date, withPattern pattern: Pattern) -> Date? {
		switch pattern {
        case .daily: return nextTime(for: time)
        case .weekly: return nextTime(for: time.adding(.day, value: 6))
        case .biweekly: return nextTime(for: time.adding(.day, value: 13))
        case .monthly: return nextTime(for: time.adding(.month, value: 1).adding(.day, value: -1))
        case .yearly: return nextTime(for: time.adding(.year, value: 1).adding(.day, value: -1))
        case .byDay(let repeatEvery): return nextTime(for: time.adding(.day, value: Int(repeatEvery) - 1))
        case let .byWeek(repeatEvery, weekDays):
			return nextTimeByWeek(for: time, repeatEvery: repeatEvery, weekDays: weekDays.sorted(by: { $0.0.rawValue < $0.1.rawValue }))
		default: return currentDate
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
    
    func nextTimeByWeek(for value: Date, repeatEvery: UInt, weekDays: [DayOfWeek]) -> Date? {
		guard weekDays.count > 0 else {
			return nextTime(for: value.adding(.day, value: Int(repeatEvery * 7) - 1))
		}
		
		guard let currentDayOfWeek = currentDayOfWeek else { return nextTime(for: value.adding(.day, value: Int(repeatEvery * 7) - 1)) }
		
		let components = dateComponents(for: value)
		
		let nextDayOfWeek = weekDays.filter({ $0.rawValue > currentDayOfWeek }).first
		
		let matchingComponents = DateComponents(calendar: calendar,
		                                        hour: components.hour,
		                                        minute: components.minute,
		                                        second: components.second,
		                                        weekday: nextDayOfWeek?.rawValue ?? weekDays.first?.rawValue)

		
		return calendar.nextDate(after: nextDayOfWeek != nil ? value : value.adding(.day, value: (Int(repeatEvery) * 7) - 1),
		                         matching: matchingComponents,
		                         matchingPolicy: .nextTimePreservingSmallerComponents,
		                         repeatedTimePolicy: .first,
		                         direction: .forward)
    }
}
