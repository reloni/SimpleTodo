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
	func testDaily() {
		let result = TaskScheduler.scheduleNext(from: Date(), withPattern: .daily)
		XCTAssertEqual(Date(), result)
	}
}
