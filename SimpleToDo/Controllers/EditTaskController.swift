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

final class EditTaskController : UIViewController {
	let task: Task?
	
	let scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.bounces = true
		scroll.isUserInteractionEnabled = true
		return scroll
	}()
	
	let containerView: UIView = {
		let view = UIView()
		view.backgroundColor = Theme.Colors.backgroundLightGray
		return view
	}()
	
	let descriptionTextField: UITextViewWithPlaceholder  = {
		let text = UITextViewWithPlaceholder()
		text.placeholder = "Task description"
		text.font = Theme.Fonts.Main
		text.borderColor = Theme.Colors.lightGray
		text.borderWidth = 0.5
		text.isScrollEnabled = false
		text.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 10)
		return text
	}()
	
	let notesTextField: UITextViewWithPlaceholder = {
		let text = UITextViewWithPlaceholder()
		text.placeholder = "Task notes"
		text.font = Theme.Fonts.Main
		text.borderColor = Theme.Colors.lightGray
		text.borderWidth = 0.5
		text.isScrollEnabled = false
		text.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 10)
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
		
		view.addSubview(scrollView)
		scrollView.addSubview(containerView)
		containerView.addSubview(descriptionTextField)
		containerView.addSubview(notesTextField)
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		descriptionTextField.text = task?.description
		notesTextField.text = task?.notes
		
		updateViewConstraints()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
			appState.dispatch(AppAction.dismisEditTaskController)
			appState.dispatch(AppAction.addTask(Task(uuid: UniqueIdentifier(), completed: false, description: desc, notes: notesTextField.text)))
			return
		}
		
		let newTask = Task(uuid: task.uuid, completed: false, description: desc, notes: notesTextField.text)
		appState.dispatch(AppAction.dismisEditTaskController)
		appState.dispatch(AppAction.updateTask(newTask))
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
			make.top.equalTo(containerView.snp.top)
			make.leading.equalTo(containerView)
			make.trailing.equalTo(containerView)
		}
		notesTextField.snp.remakeConstraints { make in
			make.top.equalTo(descriptionTextField.snp.bottom).offset(10)
			make.leading.equalTo(containerView)
			make.trailing.equalTo(containerView)
			make.bottom.equalTo(containerView).inset(10)
		}
	}
}
