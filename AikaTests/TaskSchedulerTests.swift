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
		let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .daily)
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 1)), formatter.string(from: result))
	}
    
    func testDaily_inPast() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.hour, value: -3)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .daily)
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 1)), formatter.string(from: result))
    }
    
    func testDaily_inPast_2() {
        let currentDate = Date()
        let taskDate = currentDate.adding(.day, value: 2)
        let result = TaskScheduler.scheduleNext(from: taskDate, withPattern: .daily)
        XCTAssertEqual(formatter.string(from: taskDate.adding(.day, value: 1)), formatter.string(from: result))
    }
}
