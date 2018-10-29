//
//  main.swift
//  Aika
//
//  Created by Anton Efimenko on 03.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import Foundation

private func delegateClassName() -> String? {
    return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate.self) : nil
}

_ = UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>?.self,
            capacity: Int(CommandLine.argc)),
    nil,
    delegateClassName()
)
