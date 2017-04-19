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
	}
	
	final class Colors {
		static let backgroundLightGray = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
		static let appleBlue = UIColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 1)
		static let lightGray = UIColor.lightGray
		static let white = UIColor.white
	}
}
