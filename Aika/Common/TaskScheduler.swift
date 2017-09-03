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
		case byMonthDays(repeatEvery: UInt, days: [UInt8])
		case byYearMonths(repeatEvery: UInt, months: [Month])
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
	
	static var calendar: Calendar { return Calendar.current }
    
    static func dateComponents(for date: Date) -> DateComponents {
        return calendar.dateComponents([.hour, .minute, .second], from: date)
    }
    
    static var currentDayOfWeek: Int? {
        return calendar.dateComponents([.weekday], from: Date()).weekday
    }
	
	static func scheduleNext(from time: Date, withPattern pattern: Pattern) -> Date? {
		switch pattern {
        case .daily: return nextTime(for: time)
        case .weekly: return nextTime(for: time.adding(.day, value: 6))
        case .biweekly: return nextTime(for: time.adding(.day, value: 13))
        case .monthly: return nextTime(for: time.adding(.month, value: 1).adding(.day, value: -1))
        case .yearly: return nextTime(for: time.adding(.year, value: 1).adding(.day, value: -1))
        case .byDay(let repeatEvery): return nextTime(for: time.adding(.day, value: Int(repeatEvery) - 1))
        case let .byWeek(repeatEvery, weekDays): return nextTimeByWeek(for: time, repeatEvery: repeatEvery, weekDays: weekDays)
		default: return Date()
		}
	}
    
    static func nextTime(for value: Date) -> Date? {
        let components = dateComponents(for: value)

        let matchingComponents = DateComponents(calendar: calendar, hour: components.hour, minute: components.minute, second: components.second)

        return calendar.nextDate(after: value,
                                 matching: matchingComponents,
                                 matchingPolicy: .nextTimePreservingSmallerComponents,
                                 repeatedTimePolicy: .first,
                                 direction: .forward)
    }
    
    static func nextTimeByWeek(for value: Date, repeatEvery: UInt, weekDays: [DayOfWeek]) -> Date? {
        return nil
    }
}
