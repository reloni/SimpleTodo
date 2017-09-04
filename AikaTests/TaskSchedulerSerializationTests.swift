//
//  TaskSchedulerSerializationTests.swift
//  Aika
//
//  Created by Anton Efimenko on 04.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import XCTest
@testable import Aika
import Wrap

class TaskSchedulerSerializationTests: XCTestCase {
    func testSerializePattern() {
        XCTAssertEqual(try! wrap(TaskScheduler.Pattern.daily)["type"] as? String, "daily")
        
        XCTAssertEqual(try! wrap(TaskScheduler.Pattern.weekly)["type"] as? String, "weekly")
        
        XCTAssertEqual(try! wrap(TaskScheduler.Pattern.biweekly)["type"] as? String, "biweekly")
        
        XCTAssertEqual(try! wrap(TaskScheduler.Pattern.monthly)["type"] as? String, "monthly")
        
        XCTAssertEqual(try! wrap(TaskScheduler.Pattern.yearly)["type"] as? String, "yearly")
        
        let byDay: WrappedDictionary = try! wrap(TaskScheduler.Pattern.byDay(repeatEvery: 5))
        XCTAssertEqual(byDay["type"] as? String, "byDay")
        XCTAssertEqual(byDay["repeatEvery"] as? String, "5")
        
        let byWeek: WrappedDictionary = try! wrap(TaskScheduler.Pattern.byWeek(repeatEvery: 3, weekDays: [.monday, .tuesday, .friday]))
        XCTAssertEqual(byWeek["type"] as? String, "byWeek")
        XCTAssertEqual(byWeek["repeatEvery"] as? String, "3")
        XCTAssertEqual(byWeek["weekDays"] as! [Int], [2, 3, 6])
        
        let byMonthDays: WrappedDictionary = try! wrap(TaskScheduler.Pattern.byMonthDays(repeatEvery: 8, days: [3, 6, 8, 22, 30]))
        XCTAssertEqual(byMonthDays["type"] as? String, "byMonthDays")
        XCTAssertEqual(byMonthDays["repeatEvery"] as? String, "8")
        XCTAssertEqual(byMonthDays["days"] as! [UInt], [3, 6, 8, 22, 30])
    }
}

