//
//  DateToStringTests.swift
//  AikaTests
//
//  Created by Anton Efimenko on 23.12.2017.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import XCTest
import Foundation
@testable import Aika

class DateToStringTests: XCTestCase {
	let injectFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
		return dateFormatter
	}()
	
	let injectRelativeDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone.init(identifier: "UTC")
		formatter.dateStyle = .medium
		formatter.doesRelativeDateFormatting = true
		return formatter
	}()
	
	let localFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
		return dateFormatter
	}()
	
	func testFullWithinCurrentYear() {
		var date = Date().adding(.day, value: -2)
		localFormatter.dateFormat = "\(Date.DateFormat.dateWithoutYear.rawValue) \(Date.DateFormat.time12.rawValue)"
		XCTAssertEqual(localFormatter.string(from: date), date.toString(format: .full(withTime: true), dateFormatter: injectFormatter))
		
		localFormatter.dateFormat = "\(Date.DateFormat.dateWithoutYear.rawValue)"
		XCTAssertEqual(localFormatter.string(from: date), date.toString(format: .full(withTime: false), dateFormatter: injectFormatter))
		
		date = Date()
		localFormatter.dateFormat = "\(Date.DateFormat.dayOfWeek.rawValue) \(Date.DateFormat.time12.rawValue)"
		XCTAssertEqual(localFormatter.string(from: date), date.toString(format: .full(withTime: true), dateFormatter: injectFormatter))
		
		localFormatter.dateFormat = "\(Date.DateFormat.dayOfWeek.rawValue)"
		XCTAssertEqual(localFormatter.string(from: date), date.toString(format: .full(withTime: false), dateFormatter: injectFormatter))
	}
	
	func testFullInPreviousYear() {
		var date = Date().adding(.year, value: -1).adding(.day, value: -14)
		localFormatter.dateFormat = "\(Date.DateFormat.dateFull.rawValue) \(Date.DateFormat.time12.rawValue)"
		XCTAssertEqual(localFormatter.string(from: date), date.toString(format: .full(withTime: true), dateFormatter: injectFormatter))
		
		localFormatter.dateFormat = "\(Date.DateFormat.dateFull.rawValue)"
		XCTAssertEqual(localFormatter.string(from: date), date.toString(format: .full(withTime: false), dateFormatter: injectFormatter))
		
		date = Date().adding(.year, value: -1)
		localFormatter.dateFormat = "\(Date.DateFormat.dateFull.rawValue) \(Date.DateFormat.time12.rawValue)"
		XCTAssertEqual(localFormatter.string(from: date), date.toString(format: .full(withTime: true), dateFormatter: injectFormatter))
		
		localFormatter.dateFormat = "\(Date.DateFormat.dateFull.rawValue)"
		XCTAssertEqual(localFormatter.string(from: date), date.toString(format: .full(withTime: false), dateFormatter: injectFormatter))
	}
	
	func testRelativeWithinCurrentYear() {
		var date = Date().adding(.day, value: 7)
		localFormatter.dateFormat = "\(Date.DateFormat.dayOfWeek.rawValue) \(Date.DateFormat.time12.rawValue)"
		XCTAssertEqual(localFormatter.string(from: date), date.toString(format: .relative(withTime: true), dateFormatter: injectFormatter))
		
		localFormatter.dateFormat = "\(Date.DateFormat.dayOfWeek.rawValue)"
		XCTAssertEqual(localFormatter.string(from: date), date.toString(format: .relative(withTime: false), dateFormatter: injectFormatter))
		
		date = Date()
		localFormatter.dateFormat = "\(Date.DateFormat.time12.rawValue)"
		XCTAssertEqual("Today \(localFormatter.string(from: date))",
			date.toString(format: .relative(withTime: true), dateFormatter: injectFormatter, relativeDateFormatter: injectRelativeDateFormatter))
		
		localFormatter.dateFormat = "\(Date.DateFormat.dayOfWeek.rawValue)"
		XCTAssertEqual("Today",
					   date.toString(format: .relative(withTime: false), dateFormatter: injectFormatter, relativeDateFormatter: injectRelativeDateFormatter))
		
		date = Date().adding(.day, value: 1)
		localFormatter.dateFormat = "\(Date.DateFormat.time12.rawValue)"
		XCTAssertEqual("Tomorrow \(localFormatter.string(from: date))",
			date.toString(format: .relative(withTime: true), dateFormatter: injectFormatter, relativeDateFormatter: injectRelativeDateFormatter))
		
		localFormatter.dateFormat = "\(Date.DateFormat.dayOfWeek.rawValue)"
		XCTAssertEqual("Tomorrow",
					   date.toString(format: .relative(withTime: false), dateFormatter: injectFormatter, relativeDateFormatter: injectRelativeDateFormatter))
		
		date = Date().adding(.day, value: -1)
		localFormatter.dateFormat = "\(Date.DateFormat.time12.rawValue)"
		XCTAssertEqual("Yesterday \(localFormatter.string(from: date))",
			date.toString(format: .relative(withTime: true), dateFormatter: injectFormatter, relativeDateFormatter: injectRelativeDateFormatter))
		
		localFormatter.dateFormat = "\(Date.DateFormat.dayOfWeek.rawValue)"
		XCTAssertEqual("Yesterday",
					   date.toString(format: .relative(withTime: false), dateFormatter: injectFormatter, relativeDateFormatter: injectRelativeDateFormatter))
	}
}
