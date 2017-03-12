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
	let task: Task?
	let bag = DisposeBag()
	
	let scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.bounces = true
		scroll.alwaysBounceVertical = true
		scroll.isUserInteractionEnabled = true
		return scroll
	}()
	
	let containerView: UIView = {
		let view = UIView()
		view.backgroundColor = Theme.Colors.backgroundLightGray
		return view
	}()
	
	let descriptionTextField: TextView  = {
		let text = TextView()
		
		text.titleLabel = UILabel()
		text.titleLabel?.font = Theme.Fonts.textFieldTitle
		text.titleLabelColor = Theme.Colors.appleBlue
		text.titleLabelActiveColor = Theme.Colors.appleBlue
		text.titleLabel?.text = "Task description"
		text.titleLabelAnimationDistance = 1
		
		text.placeholderLabel = UILabel()
		text.placeholderLabel?.font = Theme.Fonts.main
		text.placeholderLabel?.textColor = Theme.Colors.lightGray
		text.placeholderLabel?.text = "Task description"
		
		text.font = Theme.Fonts.main
		text.borderColor = Theme.Colors.lightGray
		text.borderWidth = 0.5
		text.isScrollEnabled = false
		
		text.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 15)
		text.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
		return text
	}()
	
	let notesTextField: TextView = {
		let text = TextView()
		
		text.titleLabel = UILabel()
		text.titleLabel?.font = Theme.Fonts.textFieldTitle
		text.titleLabelColor = Theme.Colors.appleBlue
		text.titleLabelActiveColor = Theme.Colors.appleBlue
		text.titleLabel?.text = "Task notes"
		text.titleLabelAnimationDistance = 1
		
		text.placeholderLabel = UILabel()
		text.placeholderLabel?.font = Theme.Fonts.main
		text.placeholderLabel?.textColor = Theme.Colors.lightGray
		text.placeholderLabel?.text = "Task notes"
		
		text.font = Theme.Fonts.main
		text.borderColor = Theme.Colors.lightGray
		text.borderWidth = 0.5
		text.isScrollEnabled = false
		
		text.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 15)
		text.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
		return text
	}()
	
	init(task: Task?) {
		self.task = task
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let desc = task?.description {
			title = "Edit \(desc)"
		} else {
			title = "New task"
		}
		
		view.backgroundColor = Theme.Colors.backgroundLightGray
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(controllerTap))
		view.addGestureRecognizer(recognizer)
		
		view.addSubview(scrollView)
		scrollView.addSubview(containerView)
		containerView.addSubview(descriptionTextField)
		containerView.addSubview(notesTextField)
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		updateViewConstraints()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		descriptionTextField.text = task?.description
		notesTextField.text = task?.notes
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	func controllerTap(recognizer: UITapGestureRecognizer) {
		containerView.subviews.forEach {
			if let textField = $0 as? TextView, textField.isFirstResponder {
				textField.resignFirstResponder()
				return
			}
		}
	}
	
	func keyboardWillShow(_ notification: Notification) {
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: notification.keyboardHeight() + 25, right: 0)
	}
	
	func keyboardWillHide(_ notification: Notification) {
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}
	
	func done() {
		guard let desc = descriptionTextField.text, desc.characters.count > 0 else { return }
		guard let task = task else {
			let action = RxCompositeAction(actions: [EditTaskAction.dismisEditTaskController,
			                                         EditTaskAction.addTask(Task(uuid: UniqueIdentifier(), completed: false, description: desc, notes: notesTextField.text))])
			applicationStore.dispatch(action)
			return
		}
		
		let newTask = Task(uuid: task.uuid, completed: false, description: desc, notes: notesTextField.text)
		let action = RxCompositeAction(actions: [EditTaskAction.dismisEditTaskController,
		                                         EditTaskAction.updateTask(newTask)])
		applicationStore.dispatch(action)
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
			make.top.equalTo(containerView.snp.top).offset(25)
			make.leading.equalTo(containerView)
			make.trailing.equalTo(containerView)
		}
		notesTextField.snp.remakeConstraints { make in
			make.top.equalTo(descriptionTextField.snp.bottom).offset(25)
			make.leading.equalTo(containerView)
			make.trailing.equalTo(containerView)
			make.bottom.equalTo(containerView).inset(10)
		}
	}
}
