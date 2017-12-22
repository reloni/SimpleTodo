//
//  TaskDate+Extensions.swift
//  Aika
//
//  Created by Anton Efimenko on 22.12.2017.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

extension TaskDate {
	var underlineColor: UIColor? {
		switch date.type {
		case .todayPast: fallthrough
		case .past: fallthrough
		case .yesterday: return Theme.Colors.upsdelRed
		case .tomorrow: return Theme.Colors.pumkinLight
		default: return Theme.Colors.darkSpringGreen
		}
	}
	
	func toAttributedString(format: Date.DateFormats) -> NSAttributedString {
		let str = NSMutableAttributedString(string: toString(format: format))
		
		let range = NSRange(location: 0, length: str.length)
		str.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
		if let underlineColor = underlineColor {
			str.addAttribute(NSAttributedStringKey.underlineColor, value: underlineColor, range: range)
		}
		
		return str
	}
	
	func toString(format: Date.DateFormats) -> String {
		return date.toString(format: format)
	}
}
