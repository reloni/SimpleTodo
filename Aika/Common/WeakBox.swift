//
//  WeakBox.swift
//  Aika
//
//  Created by Anton Efimenko on 27.12.2017.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation

final class WeakBox<T: AnyObject> {
	weak var value: T?
	init(_ value: T) {
		self.value = value
	}
}
