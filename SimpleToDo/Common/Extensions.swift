//
//  Extensions.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 17.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation

func configure<T>(_ obj: T, config: (T) -> Void) -> T {
	config(obj)
	return obj
}

extension FileManager {
	var documentsDirectory: URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	}
}
