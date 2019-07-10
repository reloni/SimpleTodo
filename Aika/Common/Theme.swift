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
                $0.textColor = Theme.Colors.label
				$0.adjustsFontForContentSizeCategory = true
			}
		}
		
        static func textField(withStyle style: UIFont.TextStyle) -> TextField {
			return TextField().configure {
				$0.font = UIFont.preferredFont(forTextStyle: style)
				$0.adjustsFontForContentSizeCategory = true
				$0.dividerActiveColor = Theme.Colors.tint
				$0.placeholderActiveColor = Theme.Colors.tint
                $0.placeholderNormalColor = Theme.Colors.secondaryLabel
                $0.detailColor = Theme.Colors.secondaryLabel
				$0.placeholderActiveScale = 0.85
				$0.placeholderVerticalOffset = 5
                $0.textColor = Theme.Colors.label
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
		static let checked = UIImage(named: "Checked")!.tint(with: Theme.Colors.tint)!
		static let clock = UIImage(named: "Clock")!.tint(with: Theme.Colors.tint)!
		static let delete = UIImage(named: "Delete")!.tint(with: Theme.Colors.tint)!
		static let edit = UIImage(named: "Edit")!.tint(with: Theme.Colors.tint)!
		static let refresh = UIImage(named: "Refresh")!.tint(with: Theme.Colors.gray)!
		static let calendar = UIImage(named: "Calendar")!.tint(with: Theme.Colors.tint)!
		static let pushNotification = UIImage(named: "Push notification")!.tint(with: Theme.Colors.tint)!
		static let settings = UIImage(named: "Settings")!.tint(with: Theme.Colors.tint)!
		static let info = UIImage(named: "Info")!.tint(with: Theme.Colors.tint)!
		static let deleteAccount = UIImage(named: "Delete account")!.tint(with: Theme.Colors.red)!
		static let exit = UIImage(named: "Exit")!.tint(with: Theme.Colors.red)!
		static let deleteCache = UIImage(named: "Delete cache")!.tint(with: Theme.Colors.red)!
		static let add = UIImage(named: "Add")!.tint(with: Theme.Colors.tint)!
		static let sourceCode = UIImage(named: "Source code")!.tint(with: Theme.Colors.tint)!
		static let frameworks = UIImage(named: "Frameworks")!.tint(with: Theme.Colors.tint)!
		static let email = UIImage(named: "Email")!.tint(with: Theme.Colors.label)!
		static let password = UIImage(named: "Password")!.tint(with: Theme.Colors.label)!
		static let accessoryArrow = UIImage(named: "Accessory arrow")!.tint(with: Theme.Colors.gray)!
		static let questionMark = UIImage(named: "Question mark")!.tint(with: Theme.Colors.tint)!
		static let google = UIImage(named: "Google")!.tint(with: Theme.Colors.label)!
		static let facebook = UIImage(named: "Facebook")!.tint(with: Theme.Colors.label)!
		static let badge = UIImage(named: "Badge")!.tint(with: Theme.Colors.tint)!
        static let empty = checked.tint(with: Theme.Colors.background)!
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
