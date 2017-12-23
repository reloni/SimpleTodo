//
//  Date+Extensions.swift
//  Aika
//
//  Created by Anton Efimenko on 22.12.2017.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation

extension Date {
	enum DateFormat: String {
		case dateFull = "E d MMM yyyy"
		case dateWithoutYear = "E d MMM"
		case time = "HH:mm"
		case dayOfWeek = "EEEE"
	}
	
	enum DisplayDateType {
		case full(withTime: Bool)
		case relative(withTime: Bool)
		
		var withTime: Bool {
			switch self {
			case .full(let withTime): return withTime
			case .relative(let withTime): return withTime
			}
		}
	}
	
	enum DateType {
		case todayPast
		case todayFuture
		case yesterday
		case tomorrow
		case future
		case past
	}
	
	var type: DateType {
		if isToday {
			return isInPast ? .todayPast : .todayFuture
		} else if isTomorrow {
			return .tomorrow
		} else if isYesterday {
			return .yesterday
		} else if isBeforeYesterday {
			return .past
		} else {
			return .future
		}
	}
	
	func setting(_ component: Calendar.Component, value: Int) -> Date {
		return Calendar.current.date(bySetting: component, value: value, of: self)!
	}
	
	func adding(_ component: Calendar.Component, value: Int) -> Date {
		return Calendar.current.date(byAdding: component, value: value, to: self)!
	}
	
	public func beginningOfMonth() -> Date {
		let components = Calendar.current.dateComponents([.year, .month], from: self)
		return Calendar.current.date(from: components)!
	}
	
	func beginningOfDay() -> Date {
		return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
	}
	
	func beginningOfYear() -> Date {
		return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!.setting(.month, value: 1).setting(.day, value: 1)
	}
	
	func endingOfDay() -> Date {
		return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
	}
	
	var isInPast: Bool { return self < Date() }
	var isInFuture: Bool { return self < Date() }
	var isToday: Bool { return Calendar.current.isDateInToday(self) }
	var isTomorrow: Bool { return Calendar.current.isDateInTomorrow(self) }
	var isYesterday: Bool { return Calendar.current.isDateInYesterday(self) }
	var isWithinCurrentYear: Bool { return Calendar.current.component(.year, from: self) == Calendar.current.component(.year, from: Date()) }
	var isWithinNext7Days: Bool {
		let begin = Date().beginningOfDay()
		let end = Date().adding(.day, value: 7).endingOfDay()
		return self > begin && self < end
	}
	
	var isBeforeYesterday: Bool {
		let yesterday = Date().adding(.day, value: -1).beginningOfDay()
		return self < yesterday
	}
	
	var isAfterTomorrow: Bool {
		let tomorrow = Date().adding(.day, value: 1).beginningOfDay()
		return self > tomorrow
	}
	
	static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale.current
		return dateFormatter
	}()
	
	static let relativeDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale.current
		formatter.dateStyle = .medium
		formatter.doesRelativeDateFormatting = true
		return formatter
	}()
	
	static let serverDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		//2017-01-05T21:55:57.001+00
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxx"
		return formatter
	}()
	
	func toServerDateString() -> String {
		return Date.serverDateFormatter.string(from: self)
	}
	
	func toRelativeDate(dateFormatter formatter: DateFormatter = Date.relativeDateFormatter) -> String? {
		switch type {
		case .todayFuture, .todayPast, .yesterday, .tomorrow:
			return formatter.string(from: self)
		default: return nil
		}
	}
	
	static func fromServer(string: String) -> Date? {
		return Date.serverDateFormatter.date(from: string)
	}
	
	func toString(format: DisplayDateType, dateFormatter formatter: DateFormatter = Date.dateFormatter, relativeDateFormatter: DateFormatter = Date.relativeDateFormatter) -> String {
		if case .relative = format, let spelled = toRelativeDate(dateFormatter: relativeDateFormatter) {
			formatter.dateFormat = Date.DateFormat.time.rawValue
			return format.withTime ? "\(spelled) \(formatter.string(from: self))" : spelled
		}
		
		if isWithinNext7Days {
			formatter.dateFormat = format.withTime ? "\(DateFormat.dayOfWeek.rawValue) \(DateFormat.time.rawValue)" : DateFormat.dayOfWeek.rawValue
			return formatter.string(from: self)
		}
		
		if isWithinCurrentYear {
			formatter.dateFormat = format.withTime ? "\(DateFormat.dateWithoutYear.rawValue) \(DateFormat.time.rawValue)" : DateFormat.dateWithoutYear.rawValue
		} else {
			formatter.dateFormat = format.withTime ? "\(DateFormat.dateFull.rawValue) \(DateFormat.time.rawValue)" : DateFormat.dateFull.rawValue
		}
		
		return formatter.string(from: self)
	}
}
