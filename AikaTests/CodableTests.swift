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
					 "cronExpression": "{\\"type\\":\\"daily\\"}"
					}
					""".data(using: .utf8)!
		
		let result = try! JSONDecoder().decode(TaskPrototype2.self, from: data)
		XCTAssertEqual(result.uuid, UUID(uuidString: "a4f52989-d7c6-4cc0-81ae-587e3dedf911"))
		XCTAssertEqual(result.repeatPattern, .daily)
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
}
