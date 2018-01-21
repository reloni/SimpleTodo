//
//  TaskSchedulerTests.swift
//  Aika
//
//  Created by Anton Efimenko on 01.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import XCTest
import Foundation
@testable import Aika

class TaskSchedulerTests: XCTestCase {
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
	
	let defaultTaskScheduler = TaskScheduler()
    
	func testDaily_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
		let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .daily)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 1).adding(.hour, value: 3)), formatter.string(from: result))
	}
    
    func testDaily_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .daily)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.month, value: 3).adding(.day, value: 1)), formatter.string(from: result))
    }
    
    func testDaily_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .daily)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 1).adding(.hour, value: -3)), formatter.string(from: result))
    }
    
    func testDaily_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: -5)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .daily)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 1)), formatter.string(from: result))
    }
    
    func testWeekly_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .weekly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 7).adding(.hour, value: 3)), formatter.string(from: result))
    }
    
    func testWeekly_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .weekly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 7).adding(.month, value: 3)), formatter.string(from: result))
    }
    
    func testWeekly_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .weekly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 7).adding(.hour, value: -3)), formatter.string(from: result))
    }
    
    func testWeekly_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: -2)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .weekly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 7).adding(.day, value: -2)), formatter.string(from: result))
    }
    
    func testBiWeekly_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .biweekly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 14).adding(.hour, value: 3)), formatter.string(from: result))
    }
    
    func testBiWeekly_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .biweekly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.month, value: 3).adding(.day, value: 14)), formatter.string(from: result))
    }
    
    func testBiWeekly_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .biweekly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 14).adding(.hour, value: -3)), formatter.string(from: result))
    }
    
    func testBiWeekly_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: -2)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .biweekly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 14).adding(.day, value: -2)), formatter.string(from: result))
    }
    
    func testMonthly_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .monthly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.month, value: 1).adding(.hour, value: 3)), formatter.string(from: result))
    }
    
    func testMonthly_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .monthly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.month, value: 1).adding(.month, value: 3)), formatter.string(from: result))
    }
    
    func testMonthly_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .monthly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.month, value: 1).adding(.hour, value: -3)), formatter.string(from: result))
    }
    
    func testMonthly_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: -2)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .monthly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: -2).adding(.month, value: 1)), formatter.string(from: result))
    }
    
    func testYearly_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .yearly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.year, value: 1).adding(.hour, value: 3)), formatter.string(from: result))
    }
    
    func testYearly_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .yearly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.year, value: 1).adding(.month, value: 3)), formatter.string(from: result))
    }
    
    func testYearly_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .yearly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.year, value: 1).adding(.hour, value: -3)), formatter.string(from: result))
    }
    
    func testYearly_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: -2)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .yearly)!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.year, value: 1).adding(.day, value: -2)), formatter.string(from: result))
    }
    
    func testByDay_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .byDay(repeatEvery: 2))!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 2).adding(.hour, value: 3)), formatter.string(from: result))
    }
    
    func testByDay_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .byDay(repeatEvery: 55))!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.month, value: 3).adding(.day, value: 55)), formatter.string(from: result))
    }
    
    func testByDay_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .byDay(repeatEvery: 10))!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 10).adding(.hour, value: -3)), formatter.string(from: result))
    }
    
    func testByDay_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: -2)
        let result = defaultTaskScheduler.scheduleNext(from: taskDate, withPattern: .byDay(repeatEvery: 500))!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 500).adding(.day, value: -2)), formatter.string(from: result))
    }
    
    func testByWeek_1() {
		let currentDate = Date().startOfWeek()
		let scheduler = TaskScheduler(currentDate: currentDate)
		let taskDate = currentDate.adding(.hour, value: -3)
		let result = scheduler.scheduleNext(from: taskDate, withPattern: .byWeek(repeatEvery: 3, weekDays: []))!
		XCTAssertEqual(formatter.string(from: currentDate.adding(.hour, value: -3).adding(.day, value: 3 * 7)), formatter.string(from: result))
    }
	
	func testByWeek_2() {
		let currentDate = Date().startOfWeek()
		let scheduler = TaskScheduler(currentDate: currentDate)
		let taskDate = currentDate.adding(.hour, value: 10)
		let lastWeekDay = TaskScheduler.DayOfWeek(rawValue: Calendar.current.lastWeekday)!
		let result = scheduler.scheduleNext(from: taskDate, withPattern: .byWeek(repeatEvery: 3, weekDays: [lastWeekDay]))!
		XCTAssertEqual(formatter.string(from: currentDate.adding(.hour, value: 10).adding(.day, value: 6)), formatter.string(from: result))
	}
	
	func testByWeek_3() {
		let currentDate = Date().startOfWeek()
		let scheduler = TaskScheduler(currentDate: currentDate)
		let taskDate = currentDate.adding(.hour, value: -8)
		let lastWeekDay = TaskScheduler.DayOfWeek(rawValue: Calendar.current.lastWeekday)!
		let result = scheduler.scheduleNext(from: taskDate, withPattern: .byWeek(repeatEvery: 3, weekDays: [lastWeekDay]))!
		XCTAssertEqual(formatter.string(from: currentDate.adding(.hour, value: -8).adding(.day, value: 1 * 7)), formatter.string(from: result))
	}
	
	func testByWeek_4() {
		let currentDate = Date().startOfWeek()
		let scheduler = TaskScheduler(currentDate: currentDate)
		let taskDate = currentDate.adding(.hour, value: -8)
		let days = [TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 2)!,
					TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 3)!]
		let result = scheduler.scheduleNext(from: taskDate, withPattern: .byWeek(repeatEvery: 3, weekDays: days))!
		print(formatter.string(from: currentDate.adding(.hour, value: -8).adding(.day, value: 3)))
		XCTAssertEqual(formatter.string(from: currentDate.adding(.hour, value: -8).adding(.day, value: 3)), formatter.string(from: result))
		XCTAssertEqual(result, currentDate.adding(.hour, value: -8).adding(.day, value: 3))
	}
	
	func testByWeek_5() {
		let currentDate = Date().startOfWeek()
		let scheduler = TaskScheduler(currentDate: currentDate)
		let taskDate = currentDate.adding(.hour, value: 10)
		let days = [TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 3)!,
					TaskScheduler.DayOfWeek(rawValue: Calendar.current.lastWeekday + 0)!,
					TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 2)!]
		let result = scheduler.scheduleNext(from: taskDate, withPattern: .byWeek(repeatEvery: 3, weekDays: days))!
		print(formatter.string(from: currentDate.adding(.hour, value: 10).adding(.day, value: 3)))
		XCTAssertEqual(formatter.string(from: currentDate.adding(.hour, value: 10).adding(.day, value: 2)), formatter.string(from: result))
	}
	
	func testByWeek_6() {
		let currentDate = Date().startOfWeek().adding(.day, value: 3)
		let scheduler = TaskScheduler(currentDate: currentDate)
		let taskDate = currentDate.adding(.hour, value: 10)
		let days = [TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 0)!,
					TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 3)!,
					TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 1)!,
					TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 5)!]
		let result = scheduler.scheduleNext(from: taskDate, withPattern: .byWeek(repeatEvery: 3, weekDays: days))!
		print(formatter.string(from: currentDate.adding(.hour, value: 10).adding(.day, value: 2)))
		XCTAssertEqual(formatter.string(from: currentDate.adding(.hour, value: 10).adding(.day, value: 2)), formatter.string(from: result))
	}
	
	func testByWeek_7() {
		let currentDate = Date().startOfWeek().adding(.day, value: 3)
		let scheduler = TaskScheduler(currentDate: currentDate)
		let taskDate = currentDate.adding(.hour, value: 10)
		let days = [TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 3)!,
					TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 0)!]
		let result = scheduler.scheduleNext(from: taskDate, withPattern: .byWeek(repeatEvery: 3, weekDays: days))!
		print(formatter.string(from: currentDate.adding(.hour, value: 10).adding(.day, value: (3 * 7) + 4)))
		XCTAssertEqual(formatter.string(from: currentDate.adding(.hour, value: 10).adding(.day, value: (3 * 7) + 4)), formatter.string(from: result))
	}
	
	func testByWeek_8() {
		let currentDate = Date().startOfWeek().adding(.day, value: 3)
		let scheduler = TaskScheduler(currentDate: currentDate)
		let taskDate = currentDate.adding(.hour, value: 10)
		let days = [TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 3)!,
					TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 0)!]
		let result = scheduler.scheduleNext(from: taskDate, withPattern: .byWeek(repeatEvery: 1, weekDays: days))!
		XCTAssertEqual(formatter.string(from: currentDate.adding(.hour, value: 10).adding(.day, value: 7 + 4)), formatter.string(from: result))
	}
	
	func testByWeek_9() {
		let currentDate = Date().startOfWeek().adding(.day, value: 2)
		let scheduler = TaskScheduler(currentDate: currentDate)
		let taskDate = currentDate.adding(.hour, value: 10)
		let days = [TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 3)!,
					TaskScheduler.DayOfWeek(rawValue: Calendar.current.firstWeekday + 0)!]
		let result = scheduler.scheduleNext(from: taskDate, withPattern: .byWeek(repeatEvery: 1, weekDays: days))!
		XCTAssertEqual(formatter.string(from: currentDate.adding(.hour, value: 10).adding(.day, value: 1)), formatter.string(from: result))
	}
    
    func testByMonthDays_1() {
        let currentDate = Date().beginningOfMonth()
        let scheduler = TaskScheduler(currentDate: currentDate)
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = scheduler.scheduleNext(from: taskDate, withPattern: .byMonthDays(repeatEvery: 3, days: []))!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.hour, value: -3).adding(.month, value: 3)), formatter.string(from: result))
    }
    
    func testByMonthDays_2() {
        let currentDate = Date().beginningOfMonth()
        let scheduler = TaskScheduler(currentDate: currentDate)
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = scheduler.scheduleNext(from: taskDate, withPattern: .byMonthDays(repeatEvery: 3, days: [1]))!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.month, value: 2).adding(.day, value: 1).adding(.hour, value: -3)), formatter.string(from: result))
    }
    
    func testByMonthDays_3() {
        let currentDate = Date().beginningOfMonth().adding(.day, value: 5)
        let scheduler = TaskScheduler(currentDate: currentDate)
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = scheduler.scheduleNext(from: taskDate, withPattern: .byMonthDays(repeatEvery: 3, days: [1, 2, 4, 8]))!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.day, value: 3).adding(.hour, value: -3)), formatter.string(from: result))
    }
    
    func testByMonthDays_4() {
        let currentDate = Date().beginningOfMonth().adding(.day, value: 9)
        let scheduler = TaskScheduler(currentDate: currentDate)
        let taskDate = currentDate.adding(.hour, value: 10)
        let result = scheduler.scheduleNext(from: taskDate, withPattern: .byMonthDays(repeatEvery: 3, days: [1, 2, 4, 8]))!
        XCTAssertEqual(formatter.string(from: currentDate.adding(.month, value: 3).adding(.day, value: -9).adding(.hour, value: 10)), formatter.string(from: result))
    }
}
