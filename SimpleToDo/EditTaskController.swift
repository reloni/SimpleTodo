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
	
	let descriptionTextField: UITextView  = {
		let text = UITextView()
		text.font = Theme.Fonts.Main
		text.borderColor = Theme.Colors.lightGray
		text.borderWidth = 0.5
		text.isScrollEnabled = false
		text.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 10)
		return text
	}()
	
	let notesLabel: UILabel = {
		let lbl = UILabel()
		lbl.text = "Notes"
		lbl.font = Theme.Fonts.Main
		return lbl
	}()
	
	let notesTextField: UITextView = {
		let text = UITextView()
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
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		
		view.addSubview(descriptionTextField)
		view.addSubview(notesLabel)
		view.addSubview(notesTextField)
		self.view.backgroundColor = UIColor.white
		
		descriptionTextField.text = task?.description
		notesTextField.text = task?.notes
		
		updateViewConstraints()
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
		
		descriptionTextField.snp.remakeConstraints { make in
			make.top.equalTo(view.snp.topMargin).offset(0)
			make.leading.equalTo(view.snp.leading).offset(0)
			make.trailing.equalTo(view.snp.trailing).offset(0)
		}
		
		notesLabel.snp.remakeConstraints { make in
			make.top.equalTo(descriptionTextField.snp.bottom).offset(10)
			make.leading.equalTo(view.snp.leading).offset(10)
			make.trailing.equalTo(view.snp.trailing).offset(-10)
		}
		
		notesTextField.snp.remakeConstraints { make in
			make.top.equalTo(notesLabel.snp.bottom).offset(10)
			make.leading.equalTo(view.snp.leading).offset(0)
			make.trailing.equalTo(view.snp.trailing).offset(0)
		}
	}
}
