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
                $0.rowHeight = UITableView.automaticDimension
				$0.tableFooterView = UIView()
				$0.backgroundColor = Theme.Colors.secondaryBackground
                $0.separatorColor = UIColor.opaqueSeparator
			}
		}
		
        static func textView(withStyle style: UIFont.TextStyle) -> TextView {
			return TextView().configure {
				$0.font = UIFont.preferredFont(forTextStyle: style)
				$0.placeholderLabel.font = UIFont.preferredFont(forTextStyle: style)
                $0.textColor = Theme.Colors.label
				$0.adjustsFontForContentSizeCategory = true
			}
		}
		
        static func label(withStyle style: UIFont.TextStyle) -> UILabel {
			return UILabel().configure {
				$0.font = UIFont.preferredFont(forTextStyle: style)
				$0.adjustsFontForContentSizeCategory = true
			}
		}
		
        static func textField(withStyle style: UIFont.TextStyle) -> TextField {
			return TextField().configure {
				$0.font = UIFont.preferredFont(forTextStyle: style)
				$0.adjustsFontForContentSizeCategory = true
				$0.dividerActiveColor = Theme.Colors.blueberry
				$0.placeholderActiveColor = Theme.Colors.blueberry
				$0.placeholderActiveScale = 0.85
				$0.placeholderVerticalOffset = 5
			}
		}
		
        static func uiTextField(withStyle style: UIFont.TextStyle) -> UITextField {
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
		static let refresh = UIImage(named: "Refresh")!.tint(with: Theme.Colors.gray)!
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
		static let email = UIImage(named: "Email")!.tint(with: Theme.Colors.whiteColor)!
		static let password = UIImage(named: "Password")!.tint(with: Theme.Colors.whiteColor)!
		static let accessoryArrow = UIImage(named: "Accessory arrow")!.tint(with: Theme.Colors.gray)!
		static let questionMark = UIImage(named: "Question mark")!.tint(with: Theme.Colors.blueberry)!
		static let google = UIImage(named: "Google")!.tint(with: Theme.Colors.whiteColor)!
		static let facebook = UIImage(named: "Facebook")!.tint(with: Theme.Colors.whiteColor)!
		static let badge = UIImage(named: "Badge")!.tint(with: Theme.Colors.blueberry)!
        static let empty = checked.tint(with: Theme.Colors.background)!
	}
	
	final class Colors {
		static let whiteColor = UIColor.white
		static let clear = UIColor.clear
		static let darkSpringGreen = UIColor.systemGreen
		static let pumkinLight = UIColor.systemYellow
		static let pumkin = UIColor.systemOrange
		static let blueberry = UIColor.systemBlue
		static let upsdelRed = UIColor.systemRed
        static let secondaryBackground = UIColor.secondarySystemBackground
        static let background = UIColor.systemBackground
		static let label = UIColor.label
        static let secondaryLabel = UIColor.secondaryLabel
        static let gray = UIColor.systemGray
	}
}
