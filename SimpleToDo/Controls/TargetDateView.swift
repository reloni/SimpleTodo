//
//  TargetDateView.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 09.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import SnapKit
import Material

final class TargetDateView : UIView {
	private static let imageEdgeSize = 30
	
	let wrapper: UIStackView = {
		let stack = UIStackView()
		
		stack.axis = .horizontal
		stack.distribution = .fill
		stack.spacing = 10
		
		return stack
	}()
	
	let textField: UITextField = {
		let field = UITextField()
		field.font = Theme.Fonts.accesory
		field.placeholder = "Due date"
		field.isEnabled = false
		return field
	}()
	
	let clearButton: Button = {
		let button = Button(image: Theme.Images.delete)
		button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
		return button
	}()
	
	let calendarButton: Button = {
		let button = Button(image: Theme.Images.calendar)
		button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
		return button
	}()
	
	init() {
		super.init(frame: CGRect.zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		backgroundColor = Theme.Colors.white
		
		addSubview(wrapper)
		wrapper.addArrangedSubview(textField)
		wrapper.addArrangedSubview(clearButton)
		wrapper.addArrangedSubview(calendarButton)
		
		textField.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.horizontal)
		textField.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.vertical)
		textField.setContentHuggingPriority(1, for: UILayoutConstraintAxis.horizontal)
		textField.setContentHuggingPriority(1, for: UILayoutConstraintAxis.vertical)
		
		clearButton.setContentCompressionResistancePriority(700, for: UILayoutConstraintAxis.horizontal)
		clearButton.setContentCompressionResistancePriority(700, for: UILayoutConstraintAxis.vertical)
		clearButton.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.horizontal)
		clearButton.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.vertical)
		
		calendarButton.setContentCompressionResistancePriority(699, for: UILayoutConstraintAxis.horizontal)
		calendarButton.setContentCompressionResistancePriority(699, for: UILayoutConstraintAxis.vertical)
		calendarButton.setContentHuggingPriority(999, for: UILayoutConstraintAxis.horizontal)
		calendarButton.setContentHuggingPriority(999, for: UILayoutConstraintAxis.vertical)
		
		wrapper.snp.makeConstraints(makeWrapperConstraints)
		clearButton.snp.makeConstraints(makeClearButtonConstraints)
		calendarButton.snp.makeConstraints(makeCalendarButtonConstraints)
	}
	
	func makeClearButtonConstraints(maker: ConstraintMaker) {
		maker.width.equalTo(TargetDateView.imageEdgeSize)
		maker.height.equalTo(TargetDateView.imageEdgeSize)
	}
	
	func makeCalendarButtonConstraints(maker: ConstraintMaker) {
		maker.width.equalTo(TargetDateView.imageEdgeSize)
		maker.height.equalTo(TargetDateView.imageEdgeSize)
	}
	
	func makeWrapperConstraints(maker: ConstraintMaker) {
		maker.edges.equalTo(self.snp.margins)
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		wrapper.snp.updateConstraints(makeWrapperConstraints)
		clearButton.snp.updateConstraints(makeClearButtonConstraints)
		calendarButton.snp.updateConstraints(makeCalendarButtonConstraints)
	}
}
