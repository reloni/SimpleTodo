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
	
	func testEncodeTask_1() {
		let task = Task2(uuid: UUID(), completed: false, description: "Task 1", notes: nil, targetDate: nil, prototype: TaskPrototype2(uuid: UUID(), repeatPattern: nil))
		
		let json = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(task)) as! [String: Any]
		XCTAssertEqual(json["uuid"] as? String, task.uuid.uuidString)
		XCTAssertEqual(json["completed"] as? Bool, false)
		XCTAssertEqual(json["description"] as? String, "Task 1")
		XCTAssertEqual(json["notes"] as? String, nil)
		XCTAssertEqual(json["targetDate"] as? String, nil)
		XCTAssertEqual(json["targetDateIncludeTime"] as? Bool, nil)
		XCTAssertEqual(json.dictionary("prototype").value("uuid"), task.prototype.uuid.uuidString)
		XCTAssertEqual(json.dictionary("prototype").stringValue("cronExpression"), nil)
	}
	
	func testEncodeTask_2() {
		let task = Task2(uuid: UUID(), completed: true, description: "Task 1", notes: "A lot of notes",
						 targetDate: TaskDate(date: Date.fromServer(string: "2017-09-18T17:47:00.000+00")!, includeTime: true),
						 prototype: TaskPrototype2(uuid: UUID(), repeatPattern: TaskScheduler.Pattern.byDay(repeatEvery: 2)))
		
		let json = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(task)) as! [String: Any]
		XCTAssertEqual(json["uuid"] as? String, task.uuid.uuidString)
		XCTAssertEqual(json["completed"] as? Bool, true)
		XCTAssertEqual(json["description"] as? String, "Task 1")
		XCTAssertEqual(json["notes"] as? String, "A lot of notes")
		XCTAssertEqual(json["targetDate"] as? String, task.targetDate?.date.toServerDateString())
		XCTAssertNotNil(json["targetDate"] as? String)
		XCTAssertEqual(json["targetDateIncludeTime"] as? Bool, true)
		XCTAssertEqual(json.dictionary("prototype").value("uuid"), task.prototype.uuid.uuidString)
		XCTAssertEqual(json.dictionary("prototype").stringValue("cronExpression"), "{\"type\":\"byDay\",\"repeatEvery\":\"2\"}")
	}
	
	func testEncodeTask_3() {
		let task = Task2(uuid: UUID(), completed: true, description: "Task 1", notes: "A lot of notes",
						 targetDate: TaskDate(date: Date.fromServer(string: "2017-09-18T17:47:00.000+00")!, includeTime: false),
						 prototype: TaskPrototype2(uuid: UUID(), repeatPattern: TaskScheduler.Pattern.biweekly))
		
		let json = try! JSONSerialization.jsonObject(with: try! JSONEncoder().encode(task)) as! [String: Any]
		XCTAssertEqual(json["uuid"] as? String, task.uuid.uuidString)
		XCTAssertEqual(json["completed"] as? Bool, true)
		XCTAssertEqual(json["description"] as? String, "Task 1")
		XCTAssertEqual(json["notes"] as? String, "A lot of notes")
		XCTAssertEqual(json["targetDate"] as? String, task.targetDate?.date.beginningOfDay().toServerDateString())
		XCTAssertNotNil(json["targetDate"] as? String)
		XCTAssertEqual(json["targetDateIncludeTime"] as? Bool, false)
		XCTAssertEqual(json.dictionary("prototype").value("uuid"), task.prototype.uuid.uuidString)
		XCTAssertEqual(json.dictionary("prototype").stringValue("cronExpression"), "{\"type\":\"biweekly\"}")
	}
}
