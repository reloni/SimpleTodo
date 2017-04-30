//
//  EditTaskController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 31.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Material
import RxSwift
import RxDataFlow

final class EditTaskController : UIViewController {
	enum DatePickerExpandMode {
		case expanded
		case collapsed
	}
	
	let viewModel: EditTaskViewModel
	let bag = DisposeBag()
	
	var datePickerHeightConstraint: Constraint?
	
	let scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.bounces = true
		scroll.alwaysBounceVertical = true
		scroll.isUserInteractionEnabled = true
		scroll.keyboardDismissMode = .onDrag
		return scroll
	}()
	
	let containerView: UIView = {
		let view = UIView()
		view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		view.backgroundColor = Theme.Colors.backgroundLightGray
		return view
	}()
	
	let descriptionTextField: TextView  = {
		let text = Theme.Controls.textView(withStyle: .body)
	
		text.placeholderActiveColor = Theme.Colors.appleBlue
		text.placeholderNormalColor = Theme.Colors.lightGray
		text.backgroundColor = Theme.Colors.white
		text.placeholderLabel.textColor = Theme.Colors.lightGray
		text.borderColor = Theme.Colors.lightGray
		text.borderWidth = 0.5
		text.isScrollEnabled = false
		
		text.placeholderLabel.text = "Task description"
		
		text.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 15)
		text.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
		return text
	}()
	
	lazy var targetDateView: TargetDateView = {
		let view = TargetDateView()
		view.borderColor = Theme.Colors.lightGray
		view.borderWidth = 0.5
		view.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
		return view
	}()
	
	let targetDatePickerView: DatePickerView = {
		let picker = DatePickerView()
		
		picker.alpha = 0
		picker.borderColor = Theme.Colors.lightGray
		picker.borderWidth = 0.5
		picker.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		
		return picker
	}()
	
	let notesLabel: UILabel = {
		let text = Theme.Controls.label(withStyle: .body)
		text.text = "Task notes"
		text.numberOfLines = 0
		
		return text
	}()
	
	let notesWrapper: UIView = {
		let view = UIView()
		view.backgroundColor = Theme.Colors.white
		view.layoutEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		view.borderColor = Theme.Colors.lightGray
		view.borderWidth = 0.5
		return view
	}()
	
	lazy var notesStack: UIStackView = {
		let stack = UIStackView()
		
		stack.axis = .vertical
		stack.distribution = .fill
		stack.spacing = 10
		
		stack.addArrangedSubview(self.notesLabel)
		stack.addArrangedSubview(self.notesTextField)
		
		return stack
	}()
	
	let notesTextField: TextView = {
		let text = Theme.Controls.textView(withStyle: .footnote)

		text.layoutEdgeInsets = .zero
		text.textContainerInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
		text.textColor = Theme.Colors.lightGray
		text.backgroundColor = Theme.Colors.white
		text.isScrollEnabled = false
		
		return text
	}()
	
	init(viewModel: EditTaskViewModel) {
		self.viewModel = viewModel
		
		descriptionTextField.text = viewModel.taskDescription.value
		notesTextField.text = viewModel.taskNotes.value
		targetDatePickerView.date = viewModel.taskTargetDate.value
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = viewModel.title
		
		view.backgroundColor = Theme.Colors.backgroundLightGray
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		
		view.addSubview(scrollView)
		scrollView.addSubview(containerView)
		containerView.addSubview(descriptionTextField)
		containerView.addSubview(targetDateView)
		containerView.addSubview(targetDatePickerView)
		containerView.addSubview(notesWrapper)
		notesWrapper.addSubview(notesStack)
		
		updateViewConstraints()
		
		bind()
	}
	
	func bind() {
		NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow).observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] notification in
				self?.scrollView.updatecontentInsetFor(keyboardHeight: notification.keyboardHeight() + 25)
			}).disposed(by: bag)
		
		NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide).observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] notification in
				self?.scrollView.updatecontentInsetFor(keyboardHeight: 0)
			}).disposed(by: bag)
		
		descriptionTextField.rx.didChange.subscribe(onNext: { [weak self] _ in
			self?.viewModel.taskDescription.value = self?.descriptionTextField.text ?? ""
		}).disposed(by: bag)
		
		notesTextField.rx.didChange.subscribe(onNext: { [weak self] _ in
			self?.viewModel.taskNotes.value = self?.notesTextField.text
		}).disposed(by: bag)

		targetDatePickerView.currentDate.bindTo(viewModel.taskTargetDate).disposed(by: bag)
		
		viewModel.datePickerExpanded.skip(1).subscribe(onNext: { [weak self] isExpanded in self?.switchDatePickerExpandMode(isExpanded) }).disposed(by: bag)
		
		viewModel.taskTargetDateChanged.subscribe(onNext: { [weak self] next in self?.targetDatePickerView.date = next }).disposed(by: bag)
		
		targetDateView.calendarButton.rx.tap.subscribe(onNext: { [weak self] _ in self?.viewModel.switchDatePickerExpansion() }).disposed(by: bag)
		targetDateView.clearButton.rx.tap.subscribe(onNext: { [weak self] _ in self?.viewModel.clearTargetDate() }).disposed(by: bag)
		
		targetDatePickerView.currentDate.map { $0?.date.shortDateAndTime ?? "" }.bindTo(targetDateView.textField.rx.text).disposed(by: bag)
	}
	
	func switchDatePickerExpandMode(_ expand: Bool) {
		guard let datePickerHeightConstraint = datePickerHeightConstraint else { return }
		
		descriptionTextField.resignFirstResponder()
		notesTextField.resignFirstResponder()
		
		switch !expand {
		case true: datePickerHeightConstraint.activate()
		case false: datePickerHeightConstraint.deactivate()
		}
		
		UIView.animate(withDuration: 0.5,
		               delay: 0.0,
		               options: [.curveEaseOut],
		               animations: {
										self.targetDatePickerView.alpha = self.datePickerHeightConstraint?.isActive ?? false ? 0 : 1
										self.view.layoutIfNeeded()
		},
		               completion: nil)
	}
	
	func done() {
		viewModel.save()
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		scrollView.snp.remakeConstraints { make in
			make.edges.equalTo(view).inset(UIEdgeInsets.zero)
		}
		
		containerView.snp.remakeConstraints { make in
			make.edges.equalTo(scrollView).inset(UIEdgeInsets.zero)
			make.width.equalTo(scrollView)
		}
		
		descriptionTextField.snp.remakeConstraints { make in
			make.top.equalTo(containerView.snp.topMargin).offset(25)
			make.leading.equalTo(containerView.snp.leadingMargin)
			make.trailing.equalTo(containerView.snp.trailingMargin)
		}
		
		targetDateView.snp.remakeConstraints { make in
			make.top.equalTo(descriptionTextField.snp.bottom).offset(25)
			make.leading.equalTo(containerView.snp.leadingMargin)
			make.trailing.equalTo(containerView.snp.trailingMargin)
		}
		
		targetDatePickerView.snp.remakeConstraints { make in
			make.top.equalTo(targetDateView.snp.bottom)
			make.leading.equalTo(containerView.snp.leadingMargin)
			make.trailing.equalTo(containerView.snp.trailingMargin)
			datePickerHeightConstraint = make.height.equalTo(0).constraint
		}
		
		notesWrapper.snp.remakeConstraints { make in
			make.top.equalTo(targetDatePickerView.snp.bottom).offset(25)
			make.leading.equalTo(containerView.snp.leadingMargin)
			make.trailing.equalTo(containerView.snp.trailingMargin)
			make.bottom.equalTo(containerView.snp.bottomMargin)
		}
		
		notesStack.snp.remakeConstraints {
			$0.edges.equalTo(notesWrapper.snp.margins)
		}
	}
}
