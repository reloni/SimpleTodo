//
//  DatePickerView.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 09.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import SnapKit

final class DatePickerView : UIView {
	let datePicker: UIDatePicker = {
		let picker = UIDatePicker()
		return picker
	}()

	let timeModeSwitcher: SwitchView = {
		let switcher = SwitchView()
		switcher.titleLabel.text = "test"
		return switcher
	}()
	
	init() {
		super.init(frame: CGRect.zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		addSubview(datePicker)
		addSubview(timeModeSwitcher)
		
		datePicker.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.vertical)
		timeModeSwitcher.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.vertical)
		
		datePicker.snp.makeConstraints(makeDatePickerConstraints)
		timeModeSwitcher.snp.makeConstraints(makeTimeModeSwitcherConstraints)
	}
	
	func makeDatePickerConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(snp.top)
		maker.leading.equalTo(snp.leading)
		maker.trailing.equalTo(snp.trailing)
	}
	
	func makeTimeModeSwitcherConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(datePicker.snp.bottom).offset(10)
		maker.leading.equalTo(snp.leading)
		maker.trailing.equalTo(snp.trailing)
		maker.bottom.equalTo(snp.bottom)
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		
		datePicker.snp.updateConstraints(makeDatePickerConstraints)
		timeModeSwitcher.snp.updateConstraints(makeTimeModeSwitcherConstraints)
	}
}
