//
//  Date+Extensions.swift
//  Aika
//
//  Created by Anton Efimenko on 22.12.2017.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation

extension Locale {
    var is24HourFormat: Bool {
        return !(DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: self)?.contains("a") ?? false)
    }
    
    var timeFormat: Date.DateFormat {
        if is24HourFormat {
            return .time24
        } else {
            return .time12
        }
    }
    
    static let posix: Locale = Locale(identifier: "en_US_POSIX")
}

extension Calendar {
    static let gregorianPosix: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.posix
        return calendar
    }()
    
	var lastWeekday: Int {
		let tmp = 1 - firstWeekday
		return tmp < 0 ? abs(tmp) : tmp + 7
	}
    
    var weekdaySymbolsPosix: [String] {
        return Calendar.gregorianPosix.weekdaySymbols.map { $0.capitalized }
    }
    
    var shortWeekdaySymbolsPosix: [String] {
        return Calendar.gregorianPosix.shortWeekdaySymbols.map { $0.capitalized }
    }
}

extension Date {
	enum DateFormat: String {
		case dateFull = "E d MMM yyyy"
		case dateWithoutYear = "E d MMM"
		case time24 = "HH:mm"
        case time12 = "h:mm a"
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
	
	func type(in calendar: Calendar) -> DateType {
		if isToday(in: calendar) {
			return isInPast ? .todayPast : .todayFuture
		} else if isTomorrow(in: calendar) {
			return .tomorrow
		} else if isYesterday(in: calendar) {
			return .yesterday
		} else if isBeforeYesterday(in: calendar) {
			return .past
		} else {
			return .future
		}
	}
	
	func setting(_ component: Calendar.Component, value: Int, in calendar: Calendar) -> Date {
		return calendar.date(bySetting: component, value: value, of: self)!
	}
	
	func adding(_ component: Calendar.Component, value: Int, in calendar: Calendar) -> Date {
		return calendar.date(byAdding: component, value: value, to: self)!
	}
	
    public func beginningOfWeek(in calendar: Calendar) -> Date {
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
	public func beginningOfMonth(in calendar: Calendar) -> Date {
		let components = calendar.dateComponents([.year, .month], from: self)
		return calendar.date(from: components)!
	}
	
	func beginningOfDay(in calendar: Calendar) -> Date {
		return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
	}
	
	func beginningOfYear(in calendar: Calendar) -> Date {
        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)!.setting(.month, value: 1, in: calendar).setting(.day, value: 1, in: calendar)
	}
	
	func endingOfDay(in calendar: Calendar) -> Date {
		return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
	}
    
    func value(for component: Calendar.Component, in calendar: Calendar) -> DateComponents {
        return calendar.dateComponents([component], from: self)
    }
    
    func weekday(in calendar: Calendar) -> Int? {
        return value(for: .weekday, in: calendar).weekday
    }

    func day(in calendar: Calendar) -> Int? {
        return value(for: .day, in: calendar).day
    }

    func month(in calendar: Calendar) -> Int? {
        return value(for: .month, in: calendar).month
    }
	
	var isInPast: Bool { return self < Date() }
	var isInFuture: Bool { return self < Date() }
	func isToday(in calendar: Calendar) -> Bool {
        return calendar.isDateInToday(self)
    }
	func isTomorrow(in calendar: Calendar) -> Bool {
        return calendar.isDateInTomorrow(self)
    }
	func isYesterday(in calendar: Calendar) -> Bool {
        return calendar.isDateInYesterday(self)
    }
	func isWithinCurrentYear(in calendar: Calendar) -> Bool {
        return calendar.component(.year, from: self) == calendar.component(.year, from: Date())
    }
	func isWithinNext7Days(in calendar: Calendar) -> Bool {
		let begin = Date().beginningOfDay(in: calendar)
        let end = Date().adding(.day, value: 7, in: calendar).endingOfDay(in: calendar)
		return self > begin && self < end
	}
    func isWithinCurrentWeek(is calendar: Calendar) -> Bool {
        let begin = Date().beginningOfWeek(in: calendar)
        let end = begin.adding(.day, value: 7, in: calendar)
        return self > begin && self < end
    }
	
	func isBeforeYesterday(in calendar: Calendar) -> Bool {
        let yesterday = Date().adding(.day, value: -1, in: calendar).beginningOfDay(in: calendar)
		return self < yesterday
	}
	
	func isAfterTomorrow(in calendar: Calendar) -> Bool {
		let tomorrow = Date().adding(.day, value: 1, in: calendar).beginningOfDay(in: calendar)
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
        formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
	
	func toServerDateString() -> String {
		return Date.serverDateFormatter.string(from: self)
	}
	
	func toRelativeDate(dateFormatter formatter: DateFormatter = Date.relativeDateFormatter, in calendar: Calendar) -> String? {
		switch type(in: calendar) {
		case .todayFuture, .todayPast, .yesterday, .tomorrow:
			return formatter.string(from: self)
		default: return nil
		}
	}
	
	static func fromServer(string: String) -> Date? {
		return Date.serverDateFormatter.date(from: string)
	}
	
	func toString(format: DisplayDateType, in calendar: Calendar, dateFormatter formatter: DateFormatter = Date.dateFormatter, relativeDateFormatter: DateFormatter = Date.relativeDateFormatter) -> String {
		if case .relative = format, let spelled = toRelativeDate(dateFormatter: relativeDateFormatter, in: calendar) {
			formatter.dateFormat = formatter.locale.timeFormat.rawValue
			return format.withTime ? "\(spelled) \(formatter.string(from: self))" : spelled
		}
		
		if isWithinNext7Days(in: calendar) {
			formatter.dateFormat = format.withTime ? "\(DateFormat.dayOfWeek.rawValue) \(formatter.locale.timeFormat.rawValue)" : DateFormat.dayOfWeek.rawValue
			return formatter.string(from: self)
		}
		
		if isWithinCurrentYear(in: calendar) {
			formatter.dateFormat = format.withTime ? "\(DateFormat.dateWithoutYear.rawValue) \(formatter.locale.timeFormat.rawValue)" : DateFormat.dateWithoutYear.rawValue
		} else {
			formatter.dateFormat = format.withTime ? "\(DateFormat.dateFull.rawValue) \(formatter.locale.timeFormat.rawValue)" : DateFormat.dateFull.rawValue
		}
		
		return formatter.string(from: self)
	}
}
