//
//  CodableTests.swift
//  AikaTests
//
//  Created by Anton Efimenko on 22.10.2017.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import XCTest
@testable import Aika

class CodableTests: XCTestCase {
	func testDecodeTaskPrototype() {
		let data = """
					{
					 "uuid": "a4f52989-d7c6-4cc0-81ae-587e3dedf911",
					 "cronExpression": "{\\"type\\":\\"biweekly\\"}"
					}
					""".data(using: .utf8)!
		
		let result = try! JSONDecoder().decode(TaskPrototype2.self, from: data)
		XCTAssertEqual(result.uuid, UUID(uuidString: "a4f52989-d7c6-4cc0-81ae-587e3dedf911"))
		XCTAssertEqual(result.repeatPattern, TaskScheduler.Pattern.biweekly)
	}
	
	func testDecodeTaskPrototypeWithoutCronExpression_1() {
		let data = """
					{
					 "uuid": "a4f52989-d7c6-4cc0-81ae-587e3dedf911"
					}
					""".data(using: .utf8)!
		
		let result = try! JSONDecoder().decode(TaskPrototype2.self, from: data)
		XCTAssertEqual(result.uuid, UUID(uuidString: "a4f52989-d7c6-4cc0-81ae-587e3dedf911"))
		XCTAssertNil(result.repeatPattern)
	}
	
	func testDecodeTaskPrototypeWithoutCronExpression_2() {
		let data = """
					{
					 "uuid": "a4f52989-d7c6-4cc0-81ae-587e3dedf911",
					 "cronExpression1": "{\\"type\\":\\"daily\\"}"
					}
					""".data(using: .utf8)!
		
		let result = try! JSONDecoder().decode(TaskPrototype2.self, from: data)
		XCTAssertEqual(result.uuid, UUID(uuidString: "a4f52989-d7c6-4cc0-81ae-587e3dedf911"))
		XCTAssertNil(result.repeatPattern)
	}
	
	func testDecodeTaskPrototypeWithIncorrectCronExpression() {
		let data = """
					{
					 "uuid": "a4f52989-d7c6-4cc0-81ae-587e3dedf911",
					 "cronExpression": "{\\"type\\":\\"wrong\\"}"
					}
					""".data(using: .utf8)!
		
		let result = try! JSONDecoder().decode(TaskPrototype2.self, from: data)
		XCTAssertEqual(result.uuid, UUID(uuidString: "a4f52989-d7c6-4cc0-81ae-587e3dedf911"))
		XCTAssertNil(result.repeatPattern)
	}
	
	func testDecodeTaskDate_1() {
		let data = """
					{
					 "targetDate": "2017-09-18T17:47:00.000+00",
					 "targetDateIncludeTime": true
					}
					""".data(using: .utf8)!
		
		let result = try? JSONDecoder().decode(TaskDate.self, from: data)
		XCTAssertEqual(result?.date,  Date.fromServer(string: "2017-09-18T17:47:00.000+00")!)
		XCTAssertEqual(result?.includeTime,  true)
	}
	
	func testDecodeTaskDate_2() {
		let data = """
					{
					 "targetDate": "2017-09-18T17:47:00.000+00",
					 "targetDateIncludeTime": false
					}
					""".data(using: .utf8)!
		
		let result = try? JSONDecoder().decode(TaskDate.self, from: data)
		XCTAssertEqual(result?.date,  Date.fromServer(string: "2017-09-18T00:00:00.000+00")!.beginningOfDay())
		XCTAssertEqual(result?.includeTime,  false)
	}
	
	func testDecodeTaskDate_3() {
		let data = """
					{
					 "targetDate": "2017-09-18",
					 "targetDateIncludeTime": false
					}
					""".data(using: .utf8)!
		
		let result = try? JSONDecoder().decode(TaskDate.self, from: data)
		XCTAssertNil(result)
	}
	
	func testDecodeTask_1() {
		let data = """
					{
						"uuid": "a4f52989-d7c6-4cc0-81ae-587e3dedf911",
						"completed": false,
						"description": "Test",
						"notes": "Notes",
						"creationDate": "2017-09-17T17:46:22.694+00",
						"targetDate": "2017-09-17T18:45:00.000+00",
						"targetDateIncludeTime": true,
						"prototype": {
							"uuid": "0ff83d36-5966-43e5-a3fa-40c72a29fd1d",
							"cronExpression": ""
						}
					}
					""".data(using: .utf8)!
		
		let result = try? JSONDecoder().decode(Task2.self, from: data)
		XCTAssertEqual(result?.uuid, UUID(uuidString: "a4f52989-d7c6-4cc0-81ae-587e3dedf911"))
		XCTAssertEqual(result?.completed, false)
		XCTAssertEqual(result?.description, "Test")
		XCTAssertEqual(result?.notes, "Notes")
		XCTAssertEqual(result?.targetDate?.date, Date.fromServer(string: "2017-09-17T18:45:00.000+00")!)
		XCTAssertEqual(result?.prototype.uuid, UUID(uuidString: "0ff83d36-5966-43e5-a3fa-40c72a29fd1d"))
		XCTAssertEqual(result?.prototype.repeatPattern, nil)
	}
	
	func testDecodeTask_2() {
		let data = """
					{
						"uuid": "a4f52989-d7c6-4cc0-81ae-587e3dedf911",
						"completed": true,
						"description": "Test",
						"creationDate": "2017-09-17T17:46:22.694+00",
						"targetDate": "2017-09-17T18:45:00.000+00",
						"targetDateIncludeTime": true,
						"prototype": {
							"uuid": "0ff83d36-5966-43e5-a3fa-40c72a29fd1d",
							"cronExpression": "{\\"type\\":\\"biweekly\\"}"
						}
					}
					""".data(using: .utf8)!
		
		let result = try? JSONDecoder().decode(Task2.self, from: data)
		XCTAssertEqual(result?.uuid, UUID(uuidString: "a4f52989-d7c6-4cc0-81ae-587e3dedf911"))
		XCTAssertEqual(result?.completed, true)
		XCTAssertEqual(result?.description, "Test")
		XCTAssertEqual(result?.notes, nil)
		XCTAssertEqual(result?.targetDate?.date, Date.fromServer(string: "2017-09-17T18:45:00.000+00")!)
		XCTAssertEqual(result?.prototype.uuid, UUID(uuidString: "0ff83d36-5966-43e5-a3fa-40c72a29fd1d"))
		XCTAssertEqual(result?.prototype.repeatPattern, .biweekly)
	}
	
	func testDecodeTask_3() {
		let data = """
					{
						"uuid": "a4f52989-d7c6-4cc0-81ae-587e3dedf911",
						"completed": true,
						"description": "Test",
						"creationDate": "2017-09-17T17:46:22.694+00",
						"targetDateIncludeTime": true,
						"prototype": {
							"uuid": "0ff83d36-5966-43e5-a3fa-40c72a29fd1d",
							"cronExpression": "{\\"type\\":\\"biweekly\\"}"
						}
					}
					""".data(using: .utf8)!
		
		let result = try? JSONDecoder().decode(Task2.self, from: data)
		XCTAssertEqual(result?.uuid, UUID(uuidString: "a4f52989-d7c6-4cc0-81ae-587e3dedf911"))
		XCTAssertEqual(result?.completed, true)
		XCTAssertEqual(result?.description, "Test")
		XCTAssertEqual(result?.notes, nil)
		XCTAssertEqual(result?.targetDate, nil)
		XCTAssertEqual(result?.prototype.uuid, UUID(uuidString: "0ff83d36-5966-43e5-a3fa-40c72a29fd1d"))
		XCTAssertEqual(result?.prototype.repeatPattern, .biweekly)
	}
	
	func testDecodeTask_4() {
		let data = """
					{
						"uuid": "a4f52989-d7c6-4cc0-81ae-587e3dedf911",
						"completed": true,
						"description1": "Test",
						"creationDate": "2017-09-17T17:46:22.694+00",
						"targetDateIncludeTime": true,
						"prototype": {
							"uuid": "0ff83d36-5966-43e5-a3fa-40c72a29fd1d",
							"cronExpression": "{\\"type\\":\\"biweekly\\"}"
						}
					}
					""".data(using: .utf8)!
		
		let result = try? JSONDecoder().decode(Task2.self, from: data)
		XCTAssertNil(result)
	}
}
