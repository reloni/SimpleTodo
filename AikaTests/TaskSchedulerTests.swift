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
    
	func testDaily_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
		let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .daily)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 1)), formatter.string(from: result))
	}
    
    func testDaily_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .daily)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 1)), formatter.string(from: result))
    }
    
    func testDaily_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .daily)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 1)), formatter.string(from: result))
    }
    
    func testDaily_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: 2)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .daily)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 1)), formatter.string(from: result))
    }
    
    func testWeekly_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .weekly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 7)), formatter.string(from: result))
    }
    
    func testWeekly_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .weekly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 7)), formatter.string(from: result))
    }
    
    func testWeekly_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .weekly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 7)), formatter.string(from: result))
    }
    
    func testWeekly_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: 2)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .weekly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 7)), formatter.string(from: result))
    }
    
    func testBiWeekly_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .biweekly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 14)), formatter.string(from: result))
    }
    
    func testBiWeekly_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .biweekly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 14)), formatter.string(from: result))
    }
    
    func testBiWeekly_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .biweekly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 14)), formatter.string(from: result))
    }
    
    func testBiWeekly_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: 2)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .biweekly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 14)), formatter.string(from: result))
    }
    
    func testMonthly_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .monthly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.month, value: 1)), formatter.string(from: result))
    }
    
    func testMonthly_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .monthly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.month, value: 1)), formatter.string(from: result))
    }
    
    func testMonthly_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .monthly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.month, value: 1)), formatter.string(from: result))
    }
    
    func testMonthly_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: 2)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .monthly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.month, value: 1)), formatter.string(from: result))
    }
    
    func testYearly_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .yearly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.year, value: 1)), formatter.string(from: result))
    }
    
    func testYearly_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .yearly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.year, value: 1)), formatter.string(from: result))
    }
    
    func testYearly_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .yearly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.year, value: 1)), formatter.string(from: result))
    }
    
    func testYearly_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: 2)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .yearly)!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.year, value: 1)), formatter.string(from: result))
    }
    
    
    
    
    
    
    func testByDay_inFuture() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: 3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .byDay(repeatEvery: 2))!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 2)), formatter.string(from: result))
    }
    
    func testByDay_inFuture_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.month, value: 3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .byDay(repeatEvery: 55))!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 55)), formatter.string(from: result))
    }
    
    func testByDay_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .byDay(repeatEvery: 10))!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 10)), formatter.string(from: result))
    }
    
    func testByDay_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: 2)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .byDay(repeatEvery: 500))!
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 500)), formatter.string(from: result))
    }
}
