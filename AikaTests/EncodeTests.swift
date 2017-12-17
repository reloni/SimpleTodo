//
//  EncodeTests.swift
//  AikaTests
//
//  Created by Anton Efimenko on 17.12.2017.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import XCTest
@testable import Aika

class EncodeTests: XCTestCase {
	func testEncodeTaskPrototype_1() {
		let uuid = UUID()
		let json = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(TaskPrototype2(uuid: uuid, repeatPattern: nil))) as! [String: Any]
		XCTAssertEqual(json["uuid"] as? String, uuid.uuidString)
		XCTAssertEqual(json["pattern"] as? String, nil)
	}
	
	func testEncodeTaskPrototype_2() {
		let uuid = UUID()
		let json = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(TaskPrototype2(uuid: uuid, repeatPattern: .biweekly))) as! [String: Any]
		XCTAssertEqual(json["uuid"] as? String, uuid.uuidString)
		XCTAssertEqual(json["cronExpression"] as? String, "{\"type\":\"biweekly\"}")
	}
	
	func testEncodeTaskDate_1() {
		let taskDate = Date.fromServer(string: "2017-09-18T17:47:00.000+00")!
		let date = TaskDate(date: taskDate, includeTime: true)
		let json = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(date)) as! [String: Any]
		XCTAssertEqual(json["targetDate"] as? String, taskDate.toServerDateString())
		XCTAssertEqual(json["targetDateIncludeTime"] as? Bool, true)
	}
	
	func testEncodeTaskDate_2() {
		let taskDate = Date.fromServer(string: "2017-09-18T17:47:00.000+00")!
		let date = TaskDate(date: taskDate, includeTime: false)
		let json = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(date)) as! [String: Any]
		XCTAssertEqual(json["targetDate"] as? String, taskDate.beginningOfDay().toServerDateString())
		XCTAssertEqual(json["targetDateIncludeTime"] as? Bool, false)
	}
}
