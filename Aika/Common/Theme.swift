//
//  Theme.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 14.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

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
		
        static func textView(withStyle style: UIFont.TextStyle) -> UITextView {
            return UITextView().configure {
                $0.font = UIFont.preferredFont(forTextStyle: style)
                $0.textColor = Theme.Colors.label
                $0.adjustsFontForContentSizeCategory = true
            }
        }
		
        static func label(withStyle style: UIFont.TextStyle) -> UILabel {
			return UILabel().configure {
				$0.font = UIFont.preferredFont(forTextStyle: style)
                $0.textColor = Theme.Colors.label
				$0.adjustsFontForContentSizeCategory = true
			}
		}
		
        static func textField(withStyle style: UIFont.TextStyle) -> UITextField {
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
        static let checked = UIImage(named: "Checked")!.withTintColor(Theme.Colors.tint)
		static let clock = UIImage(named: "Clock")!.withTintColor(Theme.Colors.tint)
		static let delete = UIImage(named: "Delete")!.withTintColor(Theme.Colors.tint)
		static let edit = UIImage(named: "Edit")!.withTintColor(Theme.Colors.tint)
		static let refresh = UIImage(named: "Refresh")!.withTintColor(Theme.Colors.gray)
        static let calendar = UIImage(named: "Calendar")!.withTintColor(Theme.Colors.tint)
		static let pushNotification = UIImage(named: "Push notification")!.withTintColor(Theme.Colors.tint)
		static let settings = UIImage(named: "Settings")!.withTintColor(Theme.Colors.tint)
		static let info = UIImage(named: "Info")!.withTintColor(Theme.Colors.tint)
		static let deleteAccount = UIImage(named: "Delete account")!.withTintColor(Theme.Colors.red)
		static let exit = UIImage(named: "Exit")!.withTintColor(Theme.Colors.red)
		static let deleteCache = UIImage(named: "Delete cache")!.withTintColor(Theme.Colors.red)
		static let add = UIImage(named: "Add")!.withTintColor(Theme.Colors.tint)
		static let sourceCode = UIImage(named: "Source code")!.withTintColor(Theme.Colors.tint)
		static let frameworks = UIImage(named: "Frameworks")!.withTintColor(Theme.Colors.tint)
		static let email = UIImage(named: "Email")!.withTintColor(Theme.Colors.label)
		static let password = UIImage(named: "Password")!.withTintColor(Theme.Colors.label)
		static let accessoryArrow = UIImage(named: "Accessory arrow")!.withTintColor(Theme.Colors.gray)
		static let questionMark = UIImage(named: "Question mark")!.withTintColor(Theme.Colors.tint)
		static let google = UIImage(named: "Google")!.withTintColor(Theme.Colors.label)
		static let facebook = UIImage(named: "Facebook")!.withTintColor(Theme.Colors.label)
		static let badge = UIImage(named: "Badge")!.withTintColor(Theme.Colors.tint)
        static let empty = checked.withTintColor(Theme.Colors.background)
	}
	
	final class Colors {
		static let whiteColor = UIColor.white
		static let clear = UIColor.clear
		static let green = UIColor.systemGreen
        static let yellow = UIColor.systemYellow
        static let tint = UIColor.init(named: "Tint")!
		static let red = UIColor.systemRed
        static let secondaryBackground = UIColor.secondarySystemBackground
        static let background = UIColor.systemBackground
		static let label = UIColor.label
        static let secondaryLabel = UIColor.secondaryLabel
        static let gray = UIColor.systemGray
	}
}
