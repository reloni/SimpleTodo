//
//  UITextViewWithPlaceholder.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 16.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

final class UITextViewWithPlaceholder : UITextView {
	var placeholder: String? = nil
	var showPlaceholder = false
	var isEditing = false
	
	var mainTextColor: UIColor = UIColor.black
	
	convenience init() {
		self.init(frame: CGRect.zero, textContainer: nil)
	}
	
	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		textColor = mainTextColor
		NotificationCenter.default.addObserver(self, selector: #selector(didBeginEditing), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: self)
		NotificationCenter.default.addObserver(self, selector: #selector(didEndEditing), name: NSNotification.Name.UITextViewTextDidEndEditing, object: self)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidBeginEditing, object: self)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidEndEditing, object: self)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override var text: String! {
		willSet {
			hidePlaceholder()
		}
		didSet {
			showPlaceholderIfNeeded()
		}
	}
	
	func hidePlaceholder() {
		if showPlaceholder {
			showPlaceholder = false
			textColor = mainTextColor
			text = nil
		}
	}
	
	func showPlaceholderIfNeeded() {
		if !isEditing, let placeholder = placeholder, text.characters.count == 0, !showPlaceholder {
			text = placeholder
			textColor = Theme.Colors.lightGray
			showPlaceholder = true
		}
	}
	
	func didBeginEditing() {
		isEditing = true
		hidePlaceholder()
	}
	
	func didEndEditing() {
		isEditing = false
		showPlaceholderIfNeeded()
	}
}
