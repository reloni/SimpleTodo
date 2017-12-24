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
			return UITableView().configure {
				$0.cellLayoutMarginsFollowReadableWidth = false
				$0.layoutMargins = .zero
				$0.preservesSuperviewLayoutMargins = false
				$0.separatorInset = .zero
				$0.contentInset = .zero
				$0.estimatedRowHeight = 50
				$0.rowHeight = UITableViewAutomaticDimension
				$0.tableFooterView = UIView()
				$0.backgroundColor = Theme.Colors.isabelline
			}
		}
		
		static func textView(withStyle style: UIFontTextStyle) -> TextView {
			return TextView().configure {
				$0.font = UIFont.preferredFont(forTextStyle: style)
				$0.placeholderLabel.font = UIFont.preferredFont(forTextStyle: style)
				$0.adjustsFontForContentSizeCategory = true
			}
		}
		
		static func label(withStyle style: UIFontTextStyle) -> UILabel {
			return UILabel().configure {
				$0.font = UIFont.preferredFont(forTextStyle: style)
				$0.adjustsFontForContentSizeCategory = true
			}
		}
		
		static func textField(withStyle style: UIFontTextStyle) -> TextField {
			return TextField().configure {
				$0.font = UIFont.preferredFont(forTextStyle: style)
				$0.adjustsFontForContentSizeCategory = true
				$0.dividerActiveColor = Theme.Colors.blueberry
				$0.placeholderActiveColor = Theme.Colors.blueberry
				$0.placeholderActiveScale = 0.85
				$0.placeholderVerticalOffset = 5
			}
		}
		
		static func uiTextField(withStyle style: UIFontTextStyle) -> UITextField {
			return UITextField().configure {
				$0.font = UIFont.preferredFont(forTextStyle: style)
				$0.adjustsFontForContentSizeCategory = true
			}
		}
		
		static func scrollView() -> UIScrollView {
			return UIScrollView().configure {
				$0.bounces = true
				$0.alwaysBounceVertical = true
				$0.isUserInteractionEnabled = true
				$0.keyboardDismissMode = .onDrag
			}
		}
	}
	
	final class Images {
		static let checked = UIImage(named: "Checked")!.tint(with: Theme.Colors.blueberry)!
		static let clock = UIImage(named: "Clock")!.tint(with: Theme.Colors.blueberry)!
		static let delete = UIImage(named: "Delete")!.tint(with: Theme.Colors.blueberry)!
		static let edit = UIImage(named: "Edit")!.tint(with: Theme.Colors.blueberry)!
		static let refresh = UIImage(named: "Refresh")!.tint(with: Theme.Colors.romanSilver)!
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
		static let google = UIImage(named: "Google")!.tint(with: Theme.Colors.white)!
		static let facebook = UIImage(named: "Facebook")!.tint(with: Theme.Colors.white)!
		static let badge = UIImage(named: "Badge")!.tint(with: Theme.Colors.blueberry)!
        static let empty = checked.tint(with: Theme.Colors.white)!
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
