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
	let viewModel: EditTaskViewModel
	let bag = DisposeBag()
	
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
		let text = TextView()
		
		text.placeholderActiveColor = Theme.Colors.appleBlue
		text.placeholderNormalColor = Theme.Colors.lightGray
		text.backgroundColor = Theme.Colors.white
		text.placeholderLabel.font = Theme.Fonts.main
		text.placeholderLabel.textColor = Theme.Colors.lightGray
		text.font = Theme.Fonts.main
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
		view.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		return view
	}()
	
	let notesTextField: TextView = {
		let text = TextView()

		text.placeholderActiveColor = Theme.Colors.appleBlue
		text.placeholderNormalColor = Theme.Colors.lightGray
		text.backgroundColor = Theme.Colors.white
		text.placeholderLabel.font = Theme.Fonts.main
		text.placeholderLabel.textColor = Theme.Colors.lightGray
		text.font = Theme.Fonts.main
		text.borderColor = Theme.Colors.lightGray
		text.borderWidth = 0.5
		text.isScrollEnabled = false
		
		text.placeholder = "Task notes"
		
		text.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 15)
		text.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
		return text
	}()
	
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
		
		view.backgroundColor = Theme.Colors.backgroundLightGray
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		
		view.addSubview(scrollView)
		scrollView.addSubview(containerView)
		containerView.addSubview(descriptionTextField)
		containerView.addSubview(targetDateView)
		containerView.addSubview(notesTextField)
		
		NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow).observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] notification in
				self?.scrollView.updatecontentInsetFor(keyboardHeight: notification.keyboardHeight() + 25)
			}).disposed(by: bag)
		
		NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide).observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] notification in
				self?.scrollView.updatecontentInsetFor(keyboardHeight: 0)
			}).disposed(by: bag)

		updateViewConstraints()
		
		descriptionTextField.text = viewModel.task?.description
		notesTextField.text = viewModel.task?.notes
	}
	
	func done() {
		viewModel.save(description: descriptionTextField.text, notes: notesTextField.text)
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
		
		notesTextField.snp.remakeConstraints { make in
			make.top.equalTo(targetDateView.snp.bottom).offset(25)
			make.leading.equalTo(containerView.snp.leadingMargin)
			make.trailing.equalTo(containerView.snp.trailingMargin)
			make.bottom.equalTo(containerView.snp.bottomMargin)
		}
	}
}
