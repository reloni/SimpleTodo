//
//  TargetDateView.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 09.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import SnapKit

final class TargetDateView : UIView {	
	let textField: UITextField = {
		let field = Theme.Controls.textField(withStyle: .body)
		field.placeholder = "Due date"
		field.isEnabled = false
		field.setContentHuggingPriority(UILayoutPriority(rawValue: 751), for: .horizontal)
		field.setContentHuggingPriority(UILayoutPriority(rawValue: 751), for: .vertical)
		return field
	}()
    
    let clearButton = UIButton().configure { button in
        button.setImage(Theme.Images.delete, for: .normal)
        button.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .vertical)
        button.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
    }
    
    let calendarButton = UIButton().configure { button in
        button.setImage(Theme.Images.calendar, for: .normal)
        button.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .vertical)
        button.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
    }
	
	init() {
		super.init(frame: CGRect.zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		backgroundColor = Theme.Colors.background
		
		addSubview(textField)
		addSubview(clearButton)
		addSubview(calendarButton)
		
		textField.snp.makeConstraints(makeTextFieldConstraints(maker:))
		clearButton.snp.makeConstraints(makeClearButtonConstraints)
		calendarButton.snp.makeConstraints(makeCalendarButtonConstraints)
	}
	
	func makeTextFieldConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(snp.topMargin)
		maker.bottom.equalTo(snp.bottomMargin)
		maker.leading.equalTo(snp.leadingMargin)
//		maker.trailing.equalTo(clearButton.snp.leading).offset(-10)
	}
	
	func makeClearButtonConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(snp.topMargin)
		maker.bottom.equalTo(snp.bottomMargin)
		maker.width.equalTo(clearButton.snp.height)
		maker.trailing.equalTo(calendarButton.snp.leading).offset(-10)
	}
	
	func makeCalendarButtonConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(snp.topMargin)
		maker.bottom.equalTo(snp.bottomMargin)
		maker.width.equalTo(calendarButton.snp.height)
		maker.trailing.equalTo(self.snp.trailingMargin)
	}
	
	func makeWrapperConstraints(maker: ConstraintMaker) {
		maker.edges.equalTo(self.snp.margins)
	}
}
