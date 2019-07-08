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

	let scrollView = Theme.Controls.scrollView()
	
	let containerView = UIView().configure {
		$0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		$0.backgroundColor = Theme.Colors.background
	}
	
	let descriptionTextField = Theme.Controls.textView(withStyle: .body).configure {
		$0.backgroundColor = Theme.Colors.background
		$0.placeholderLabel.textColor = Theme.Colors.secondaryLabel
		$0.borderColor = Theme.Colors.gray
		$0.layer.borderWidth = 0.5
		$0.isScrollEnabled = false
		$0.placeholderLabel.text = "Task description"
		$0.textContainerInset = UIEdgeInsets(top: 15, left: 5, bottom: 15, right: 15)
	}
	
	let targetDateView = TargetDateView().configure {
		$0.borderColor = Theme.Colors.gray
		$0.layer.borderWidth = 0.5
		$0.layoutMargins = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
	}
	
	let targetDatePickerView = DatePickerView().configure {
		$0.alpha = 0
		$0.borderColor = Theme.Colors.gray
		$0.layer.borderWidth = 0.5
		$0.layoutMargins = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
		$0.date = nil
	}
	
	let taskRepeatDescriptionView = TaskRepeatDescriptionView().configure {
		$0.borderColor = Theme.Colors.gray
		$0.layer.borderWidth = 0.5
		$0.layoutMargins = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
	}
	
	let notesLabel = Theme.Controls.label(withStyle: .body).configure {
		$0.text = "Task notes"
		$0.numberOfLines = 0
	}
	
	let notesWrapper = UIView().configure {
		$0.backgroundColor = Theme.Colors.background
		$0.layoutEdgeInsets = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
		$0.borderColor = Theme.Colors.gray
		$0.layer.borderWidth = 0.5
	}
	
	lazy var notesStack = UIStackView().configure { [unowned self] in
		$0.axis = .vertical
		$0.distribution = .fill
		$0.spacing = 10
        $0.layoutMargins = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        $0.isLayoutMarginsRelativeArrangement = true
		$0.addArrangedSubview(self.notesLabel)
		$0.addArrangedSubview(self.notesTextField)
	}
	
	let notesTextField = Theme.Controls.textView(withStyle: .callout).configure {
		$0.layoutEdgeInsets = .zero
		$0.textContainerInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
		$0.textColor = Theme.Colors.secondaryLabel
		$0.backgroundColor = Theme.Colors.background
		$0.isScrollEnabled = false
	}
	
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
		view.backgroundColor = Theme.Colors.background
		
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
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] notification in
				self?.scrollView.updatecontentInsetFor(keyboardHeight: notification.keyboardHeight() + 25)
			}).disposed(by: bag)
		
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] notification in
				self?.scrollView.updatecontentInsetFor(keyboardHeight: 0)
			}).disposed(by: bag)
		
		let state = viewModel.state.share(replay: 1, scope: .forever)
		
		let datePickerExpanded = targetDateView.calendarButton.rx.tap
			.withLatestFrom(state.map { !$0.datePickerExpanded })
		
		let editRepeatModeEvent = taskRepeatDescriptionView.rx.tapGesture().when(.recognized).flatMap { _ in Observable<Void>.just(()) }
		
		viewModel.subscribe(taskDescription: descriptionTextField.rx.didChange.map { [weak self] _ in return self?.descriptionTextField.text ?? "" }.distinctUntilChanged(),
		                    taskNotes: notesTextField.rx.didChange.map { [weak self] _ in return self?.notesTextField.text }.distinctUntilChanged { $0 == $1 },
		                    taskTargetDate: targetDatePickerView.currentDate.skip(1).distinctUntilChanged { $0 == $1 },
		                    datePickerExpanded: datePickerExpanded,
		                    clearTargetDate: targetDateView.clearButton.rx.tap.flatMap { Observable<Void>.just(()) },
		                    saveChanges: saveSubject.asObservable(),
		                    editRepeatMode: editRepeatModeEvent)
				.forEach { bag.insert($0) }
		
		state.take(1).map { $0.description }.bind(to: descriptionTextField.rx.text).disposed(by: bag)
		state.take(1).map { $0.notes }.bind(to: notesTextField.rx.text).disposed(by: bag)
		state.map { $0.targetDate }.distinctUntilChanged({ $0 == $1 }).do(onNext: { [weak self] in self?.targetDatePickerView.date = $0 }).subscribe().disposed(by: bag)
		
		state.map { $0.description.count > 0 }.bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled).disposed(by: bag)
        state.map { $0.repeatPattern?.description ?? "" }.subscribe(onNext: { [unowned label = taskRepeatDescriptionView.rightLabel] value in
            UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve, animations: { label.text = value }, completion: nil)
        }).disposed(by: bag)
		targetDatePickerView.currentDate
			.map { $0?.toString(format: .full(withTime: $0?.includeTime ?? false)) ?? "" }
			.bind(to: targetDateView.textField.rx.text)
			.disposed(by: bag)
		
		state.skip(1).map { $0.targetDate != nil }.distinctUntilChanged().do(onNext: { [weak self] selected in self?.changeTaskRepeatDescriptionExpandMode(selected) }).subscribe().disposed(by: bag)
		state.skip(1).map { $0.datePickerExpanded }.distinctUntilChanged().do(onNext: { [weak self] in self?.switchDatePickerExpandMode($0) }).subscribe().disposed(by: bag)
		
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(targetDateTextFieldTapped(_:)))
		targetDateView.textField.superview?.addGestureRecognizer(recognizer)
	}
	
	@objc func targetDateTextFieldTapped(_ gesture: UITapGestureRecognizer) {
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
	
	@objc func done() {
		saveSubject.onNext(())
	}
}
