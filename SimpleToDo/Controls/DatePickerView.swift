//
//  DatePickerView.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 09.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

final class DatePickerView : UIView {
	let bag = DisposeBag()
	
	let datePicker: UIDatePicker = {
		let picker = UIDatePicker()
		return picker
	}()

	let timeModeSwitcher: SwitchView = {
		let switcher = SwitchView()
		switcher.titleLabel.text = "Include time"
		return switcher
	}()
	
	private let currentDateSubject = BehaviorSubject<Date?>(value: nil)
	var currentDate: Observable<Date?> { return currentDateSubject }
	var date: Date? = nil {
		didSet {
			if date == nil { currentDateSubject.onNext(nil) }
		}
	}
	
	init() {
		super.init(frame: CGRect.zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		clipsToBounds = true
		
		addSubview(datePicker)
		addSubview(timeModeSwitcher)
		
		datePicker.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.vertical)
		timeModeSwitcher.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.vertical)
		
		datePicker.datePickerMode = .date
		
		datePicker.rx.date.skip(1).bindTo(currentDateSubject).disposed(by: bag)
		
		timeModeSwitcher.switchControl.rx.isOn.subscribe(onNext: { [weak self] isOn in
			if isOn { self?.changeDateMode(.dateAndTime) } else { self?.changeDateMode(.date) }
		}).disposed(by: bag)
		
		datePicker.snp.makeConstraints(makeDatePickerConstraints)
		timeModeSwitcher.snp.makeConstraints(makeTimeModeSwitcherConstraints)
	}
	
	func changeDateMode(_ mode: UIDatePickerMode) {
		UIView.transition(with: datePicker,
		                  duration: 0.3,
		                  options: [.beginFromCurrentState],
		                  animations: { self.datePicker.datePickerMode = mode },
		                  completion: nil)
	}
	
	func makeDatePickerConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(snp.topMargin)
		maker.leading.equalTo(snp.leadingMargin)
		maker.trailing.equalTo(snp.trailingMargin)
	}
	
	func makeTimeModeSwitcherConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(datePicker.snp.bottom).offset(10)
		maker.leading.equalTo(snp.leadingMargin)
		maker.trailing.equalTo(snp.trailingMargin)
		maker.bottom.equalTo(snp.bottomMargin)
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		
		datePicker.snp.updateConstraints(makeDatePickerConstraints)
		timeModeSwitcher.snp.updateConstraints(makeTimeModeSwitcherConstraints)
	}
}
