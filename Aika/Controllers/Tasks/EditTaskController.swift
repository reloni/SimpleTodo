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
import RxGesture

final class EditTaskController : UIViewController {
	enum DatePickerExpandMode {
		case expanded
		case collapsed
	}
	
	let viewModel: EditTaskViewModel
	let bag = DisposeBag()
	
	var datePickerHeightConstraint: Constraint?
	var taskRepeatDescriptionViewHeightConstraint: Constraint?
	
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
		view.backgroundColor = Theme.Colors.isabelline
		return view
	}()
	
	let descriptionTextField: TextView  = {
		let text = Theme.Controls.textView(withStyle: .body)
	
		text.placeholderActiveColor = Theme.Colors.blueberry
		text.placeholderNormalColor = Theme.Colors.romanSilver
		text.backgroundColor = Theme.Colors.white
		text.placeholderLabel.textColor = Theme.Colors.romanSilver
		text.borderColor = Theme.Colors.romanSilver
		text.borderWidth = 0.5
		text.isScrollEnabled = false
		
		text.placeholderLabel.text = "Task description"
		
		text.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 15)
		return text
	}()
	
	lazy var targetDateView: TargetDateView = {
		let view = TargetDateView()
		view.borderColor = Theme.Colors.romanSilver
		view.borderWidth = 0.5
		view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		return view
	}()
	
	let targetDatePickerView: DatePickerView = {
		let picker = DatePickerView()
		
		picker.alpha = 0
		picker.borderColor = Theme.Colors.romanSilver
		picker.borderWidth = 0.5
		picker.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		picker.date = nil
		
		return picker
	}()
	
	let taskRepeatDescriptionView: TaskRepeatDescriptionView = {
		let view = TaskRepeatDescriptionView()
		view.borderColor = Theme.Colors.romanSilver
		view.borderWidth = 0.5
		view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		return view
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
		view.borderColor = Theme.Colors.romanSilver
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
		let text = Theme.Controls.textView(withStyle: .callout)

		text.layoutEdgeInsets = .zero
		text.textContainerInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
		text.textColor = Theme.Colors.romanSilver
		text.backgroundColor = Theme.Colors.white
		text.isScrollEnabled = false
		
		return text
	}()
	
	let saveSubject = PublishSubject<Void>()
	
	init(viewModel: EditTaskViewModel) {
		self.viewModel = viewModel
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = viewModel.title
		
		view.backgroundColor = Theme.Colors.isabelline
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		
		view.addSubview(scrollView)
		scrollView.addSubview(containerView)
		containerView.addSubview(descriptionTextField)
		containerView.addSubview(targetDateView)
		containerView.addSubview(targetDatePickerView)
		containerView.addSubview(taskRepeatDescriptionView)
		containerView.addSubview(notesWrapper)
		notesWrapper.addSubview(notesStack)
		
		scrollView.snp.makeConstraints(scrollViewConstraints(make:))
		containerView.snp.makeConstraints(containerViewConstraints(make:))
		descriptionTextField.snp.makeConstraints(descriptionTextFieldConstraints(make:))
		targetDateView.snp.makeConstraints(targetDateViewConstraints(make:))
		targetDatePickerView.snp.makeConstraints(targetDatePickerViewConstraints(make:))
		taskRepeatDescriptionView.snp.makeConstraints(taskRepeatDescriptionViewConstraints(make:))
		notesWrapper.snp.makeConstraints(notesWrapperConstraints(make:))
		notesStack.snp.makeConstraints(notesStackConstraints(make:))
		
		bind()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		viewModel.state.take(1)
			.filter { $0.currentTask == nil && $0.description.isEmpty }
			.do(onNext: { [weak self] _ in self?.descriptionTextField.becomeFirstResponder() })
			.subscribe()
			.disposed(by: bag)
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
		
		let state = viewModel.state.shareReplay(1)
		
		let datePickerExpanded = targetDateView.calendarButton.rx.tap
			.withLatestFrom(state.map { !$0.datePickerExpanded })
		
		let editRepeatModeEvent = taskRepeatDescriptionView.rx.tapGesture().when(.recognized).flatMap { _ in Observable<Void>.just() }
		
		viewModel.subscribe(taskDescription: descriptionTextField.rx.didChange.map { [weak self] _ in return self?.descriptionTextField.text ?? "" }.distinctUntilChanged(),
		                    taskNotes: notesTextField.rx.didChange.map { [weak self] _ in return self?.notesTextField.text }.distinctUntilChanged { $0.0 == $0.1 },
		                    taskTargetDate: targetDatePickerView.currentDate.skip(1).distinctUntilChanged { $0.0 == $0.1 },
		                    datePickerExpanded: datePickerExpanded,
		                    clearTargetDate: targetDateView.clearButton.rx.tap.flatMap { Observable<Void>.just() },
		                    saveChanges: saveSubject.asObservable(),
		                    editRepeatMode: editRepeatModeEvent)
				.forEach { bag.insert($0) }
		
		state.take(1).map { $0.description }.bind(to: descriptionTextField.rx.text).disposed(by: bag)
		state.take(1).map { $0.notes }.bind(to: notesTextField.rx.text).disposed(by: bag)
		state.map { $0.targetDate }.distinctUntilChanged({ $0.0 == $0.1 }).do(onNext: { [weak self] in self?.targetDatePickerView.date = $0 }).subscribe().disposed(by: bag)
		
		state.map { $0.description.characters.count > 0 }.bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled).disposed(by: bag)
		state.map { $0.repeatPattern?.description ?? "" }.bind(to: taskRepeatDescriptionView.rightLabel.rx.text).disposed(by: bag)
		targetDatePickerView.currentDate.map { $0?.toString(withSpelling: false) ?? "" }.bind(to: targetDateView.textField.rx.text).disposed(by: bag)
		
		state.skip(1).map { $0.targetDate != nil }.distinctUntilChanged().do(onNext: { [weak self] selected in self?.changeTaskRepeatDescriptionExpandMode(selected) }).subscribe().disposed(by: bag)
		state.skip(1).map { $0.datePickerExpanded }.distinctUntilChanged().do(onNext: { [weak self] in self?.switchDatePickerExpandMode($0) }).subscribe().disposed(by: bag)
		
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(targetDateTextFieldTapped(_:)))
		targetDateView.textField.superview?.addGestureRecognizer(recognizer)
	}
	
	func targetDateTextFieldTapped(_ gesture: UITapGestureRecognizer) {
		guard gesture.state == .ended else { return }
		targetDateView.calendarButton.sendActions(for: .touchUpInside)
	}
	
	func changeTaskRepeatDescriptionExpandMode(_ expand: Bool) {
		guard let taskRepeatDescriptionViewHeightConstraint = taskRepeatDescriptionViewHeightConstraint else { return }
		
		switch !expand {
		case true: taskRepeatDescriptionViewHeightConstraint.activate()
		case false: taskRepeatDescriptionViewHeightConstraint.deactivate()
		}
		
		UIView.animate(withDuration: 0.5,
		               delay: 0.0,
		               options: [.curveEaseOut],
		               animations: { self.view.layoutIfNeeded() },
		               completion: nil)
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
		saveSubject.onNext()
	}
}
