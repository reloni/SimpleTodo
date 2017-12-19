//
//  Configure.swift
//  Aika
//
//  Created by Anton Efimenko on 19.12.2017.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation

public protocol Then { }

extension Then where Self: AnyObject {
	public func configure(_ block: (Self) -> Void) -> Self {
		block(self)
		return self
	}
}

extension NSObject: Then { }
