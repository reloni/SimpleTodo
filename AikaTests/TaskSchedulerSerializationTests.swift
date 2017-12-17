//
//  TaskSchedulerSerializationTests.swift
//  Aika
//
//  Created by Anton Efimenko on 04.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import XCTest
@testable import Aika
class TaskSchedulerSerializationTests: XCTestCase {
    func testSerializePattern() {
        XCTAssertEqual(TaskScheduler.Pattern.daily.toJson()["type"] as? String, "daily")
        
        XCTAssertEqual(TaskScheduler.Pattern.weekly.toJson()["type"] as? String, "weekly")
        
        XCTAssertEqual(TaskScheduler.Pattern.biweekly.toJson()["type"] as? String, "biweekly")
        
        XCTAssertEqual(TaskScheduler.Pattern.monthly.toJson()["type"] as? String, "monthly")
        
        XCTAssertEqual(TaskScheduler.Pattern.yearly.toJson()["type"] as? String, "yearly")
        
        let byDay = TaskScheduler.Pattern.byDay(repeatEvery: 5).toJson()
        XCTAssertEqual(byDay["type"] as? String, "byDay")
        XCTAssertEqual(byDay["repeatEvery"] as? String, "5")
        
        let byWeek = TaskScheduler.Pattern.byWeek(repeatEvery: 3, weekDays: [.monday, .tuesday, .friday]).toJson()
        XCTAssertEqual(byWeek["type"] as? String, "byWeek")
        XCTAssertEqual(byWeek["repeatEvery"] as? String, "3")
        XCTAssertEqual(byWeek["weekDays"] as! [Int], [2, 3, 6])
        
        let byMonthDays = TaskScheduler.Pattern.byMonthDays(repeatEvery: 8, days: [3, 6, 8, 22, 30]).toJson()
        XCTAssertEqual(byMonthDays["type"] as? String, "byMonthDays")
        XCTAssertEqual(byMonthDays["repeatEvery"] as? String, "8")
        XCTAssertEqual(byMonthDays["days"] as! [UInt], [3, 6, 8, 22, 30])
    }
	
	func testParsePattern() {
		let daily = try! (["type": "daily"] as [String: Any]).toJsonString()!
		XCTAssertEqual(TaskScheduler.Pattern.daily, TaskScheduler.Pattern.parse(fromJson: daily))
		
		let weekly = try! (["type": "weekly"] as [String: Any]).toJsonString()!
		XCTAssertEqual(TaskScheduler.Pattern.weekly, TaskScheduler.Pattern.parse(fromJson: weekly))
		
		let biweekly = try! (["type": "biweekly"] as [String: Any]).toJsonString()!
		XCTAssertEqual(TaskScheduler.Pattern.biweekly, TaskScheduler.Pattern.parse(fromJson: biweekly))
		
		let monthly = try! (["type": "monthly"] as [String: Any]).toJsonString()!
		XCTAssertEqual(TaskScheduler.Pattern.monthly, TaskScheduler.Pattern.parse(fromJson: monthly))
		
		let yearly = try! (["type": "yearly"] as [String: Any]).toJsonString()!
		XCTAssertEqual(TaskScheduler.Pattern.yearly, TaskScheduler.Pattern.parse(fromJson: yearly))
		
		let byDay = try! (["type": "byDay", "repeatEvery": 6] as [String: Any]).toJsonString()!
		XCTAssertEqual(TaskScheduler.Pattern.byDay(repeatEvery: 6), TaskScheduler.Pattern.parse(fromJson: byDay))
		
		let byWeek = try! (["type": "byWeek", "repeatEvery": 21, "weekDays": [2, -1, 4, 6, 9]] as [String: Any]).toJsonString()!
		XCTAssertEqual(TaskScheduler.Pattern.byWeek(repeatEvery: 21, weekDays: [.monday, .wednesday, .friday]), TaskScheduler.Pattern.parse(fromJson: byWeek))
		
		let byMonthDays = try! (["type": "byMonthDays", "repeatEvery": 61, "days": [1, 6, 6, 8, 22, 22, 35, -1]] as [String: Any]).toJsonString()!
		XCTAssertEqual(TaskScheduler.Pattern.byMonthDays(repeatEvery: 61, days: [1, 6, 8, 22]), TaskScheduler.Pattern.parse(fromJson: byMonthDays))
		
		let wrong1 = try! (["type1": "yearly"] as [String: Any]).toJsonString()!
		XCTAssertNil(TaskScheduler.Pattern.parse(fromJson: wrong1))
		
		let wrong2 = try! (["type": "byWeek2", "repeatEvery": 21, "weekDays": [2, -1, 4, 6, 9]] as [String: Any]).toJsonString()!
		XCTAssertNil(TaskScheduler.Pattern.parse(fromJson: wrong2))
		
		let wrong3 = try! (["type": "byWeek", "repeatEvery": 21, "weekDays2": [2, -1, 4, 6, 9]] as [String: Any]).toJsonString()!
		XCTAssertNil(TaskScheduler.Pattern.parse(fromJson: wrong3))
		
		let wrong4 = try! (["type": "byDay", "repeatEvery": -6] as [String: Any]).toJsonString()!
		XCTAssertNil(TaskScheduler.Pattern.parse(fromJson: wrong4))
	}
}

