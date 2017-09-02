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
	
	enum DayOfWeek {
		case sunday
		case monday
		case tuesday
		case wednesday
		case thursday
		case friday
		case saturday
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
	
	static func scheduleNext(from time: Date, withPattern pattern: Pattern) -> Date {
		switch pattern {
		case .daily: return nextTimeDaily(time)
		default: return Date()
		}
	}
	
	static func nextTimeDaily(_ value: Date) -> Date {
		let components = calendar.dateComponents([.hour, .minute, .second], from: value)
		
		return calendar.nextDate(after: value,
		                         matching: DateComponents(calendar: calendar, hour: components.hour, minute: components.minute, second: components.second),
		                         matchingPolicy: .nextTimePreservingSmallerComponents,
		                         repeatedTimePolicy: .first,
		                         direction: .forward)!
	}
}
