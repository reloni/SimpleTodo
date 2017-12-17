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
}
