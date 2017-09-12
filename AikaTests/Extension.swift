//
//  Extension.swift
//  Aika
//
//  Created by Anton Efimenko on 02.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation

extension Date {    
    public static func fromString(_ value: String, timezone: TimeZone = TimeZone.current) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = timezone
        return formatter.date(from: value)
    }
	
	public func startOfWeek() -> Date {
		return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
	}
	
    public func adding(_ component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }
}
