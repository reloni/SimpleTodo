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
		static func tableView() -> UITableView {
			let table = UITableView()
			
			table.cellLayoutMarginsFollowReadableWidth = false
			table.layoutMargins = .zero
			table.preservesSuperviewLayoutMargins = false
			table.separatorInset = .zero
			table.contentInset = .zero
			table.estimatedRowHeight = 50
			table.rowHeight = UITableViewAutomaticDimension
			table.tableFooterView = UIView()
			table.backgroundColor = Theme.Colors.isabelline
			
			return table
		}
		
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
		static let checked = UIImage(named: "Checked")!.tint(with: Theme.Colors.blueberry)!
		static let clock = UIImage(named: "Clock")!.tint(with: Theme.Colors.blueberry)!
		static let delete = UIImage(named: "Delete")!.tint(with: Theme.Colors.blueberry)!
		static let edit = UIImage(named: "Edit")!.tint(with: Theme.Colors.blueberry)!
		static let refresh = UIImage(named: "Refresh")!.tint(with: Theme.Colors.blueberry)!
		static let calendar = UIImage(named: "Calendar")!.tint(with: Theme.Colors.blueberry)!
		static let pushNotification = UIImage(named: "Push notification")!.tint(with: Theme.Colors.blueberry)!
		static let settings = UIImage(named: "Settings")!.tint(with: Theme.Colors.blueberry)!
		static let info = UIImage(named: "Info")!.tint(with: Theme.Colors.blueberry)!
		static let deleteAccount = UIImage(named: "Delete account")!.tint(with: Theme.Colors.upsdelRed)!
		static let exit = UIImage(named: "Exit")!.tint(with: Theme.Colors.upsdelRed)!
		static let deleteCache = UIImage(named: "Delete cache")!.tint(with: Theme.Colors.upsdelRed)!
		static let add = UIImage(named: "Add")!.tint(with: Theme.Colors.blueberry)!
		static let sourceCode = UIImage(named: "Source code")!.tint(with: Theme.Colors.blueberry)!
		static let frameworks = UIImage(named: "Frameworks")!.tint(with: Theme.Colors.blueberry)!
		static let email = UIImage(named: "Email")!.tint(with: Theme.Colors.white)!
		static let password = UIImage(named: "Password")!.tint(with: Theme.Colors.white)!
		static let accessoryArrow = UIImage(named: "Accessory arrow")!.tint(with: Theme.Colors.romanSilver)!
		static let questionMark = UIImage(named: "Question mark")!.tint(with: Theme.Colors.blueberry)!
	}
	
	final class Colors {
		static let white = UIColor.white
		static let black = UIColor.black
		static let clear = UIColor.clear
		
		static let darkSpringGreen = UIColor(red: 17/255, green: 134/255, blue: 72/255, alpha: 1)
		
		static let pumkinLight = UIColor(red: 250/255, green: 217/255, blue: 97/255, alpha: 1)
		static let pumkin = UIColor(red: 247/255, green: 107/255, blue: 28/255, alpha: 1)
		static let blueberry = UIColor(red: 67/255, green: 146/255, blue: 241/255, alpha: 1)
		static let upsdelRed = UIColor(red: 176/255, green: 32/255, blue: 50/255, alpha: 1)
		static let romanSilver = UIColor(red: 133/255, green: 138/255, blue: 149/255, alpha: 1)
		static let isabelline = UIColor(red: 237/255, green: 236/255, blue: 236/255, alpha: 1)
		
	}
}
