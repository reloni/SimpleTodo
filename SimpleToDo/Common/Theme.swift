//
//  Theme.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 14.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import Material

final class Theme {
	final class Controls {
		static func textView(withStyle style: UIFontTextStyle) -> TextView {
			let control = TextView()
			control.font = UIFont.preferredFont(forTextStyle: style)
			control.placeholderLabel.font = UIFont.preferredFont(forTextStyle: style)
			control.adjustsFontForContentSizeCategory = true
			return control
		}
		
		static func label(withStyle style: UIFontTextStyle) -> UILabel {
			let control = UILabel()
			control.font = UIFont.preferredFont(forTextStyle: style)
			control.adjustsFontForContentSizeCategory = true
			return control
		}
		
		static func textField(withStyle style: UIFontTextStyle) -> TextField {
			let control = TextField()
			control.font = UIFont.preferredFont(forTextStyle: style)
			control.adjustsFontForContentSizeCategory = true
			control.dividerActiveColor = Theme.Colors.blueberry
			control.placeholderActiveColor = Theme.Colors.blueberry
			return control
		}
		
		static func uiTextField(withStyle style: UIFontTextStyle) -> UITextField {
			let control = UITextField()
			control.font = UIFont.preferredFont(forTextStyle: style)
			control.adjustsFontForContentSizeCategory = true
			return control
		}
	}
	
	final class Images {
		static let checked = UIImage(named: "Checked")
		static let clock = UIImage(named: "Clock")
		static let delete = UIImage(named: "Delete")
		static let edit = UIImage(named: "Edit")
		static let trash = UIImage(named: "Trash")
		static let refresh = UIImage(named: "Refresh")
		static let calendar = UIImage(named: "Calendar")
		static let pushNotification = UIImage(named: "Push notification")
	}
	
	final class Colors {
		static let lightGray = UIColor.lightGray
		static let white = UIColor.white
		
		static let pumkinLight = UIColor(red: 250/255, green: 217/255, blue: 97/255, alpha: 1)
		static let pumkin = UIColor(red: 247/255, green: 107/255, blue: 28/255, alpha: 1)
		static let blueberry = UIColor(red: 67/255, green: 146/255, blue: 241/255, alpha: 1)
		static let sunny = UIColor(red: 255/255, green: 242/255, blue: 117/255, alpha: 1)
		static let isabelline = UIColor(red: 237/255, green: 236/255, blue: 236/255, alpha: 1)
		static let jet = UIColor(red: 52/255, green: 46/255, blue: 55/255, alpha: 1)
		
	}
}
