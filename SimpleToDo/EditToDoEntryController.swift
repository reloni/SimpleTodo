//
//  EditToDoEntryController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 31.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Material

final class EditToDoEntryController : UIViewController {
	let entry: ToDoEntry?
	
	lazy var completed: Switch = {
		let sw = Switch()
		sw.bounceable = true
		sw.on = self.entry?.completed ?? false
		return sw
	}()
	
	let descriptionTextField: TextField  = {
		let text = TextField()
		text.placeholder = "Description"
		return text
	}()
	
	let notesTextField: UITextView = {
		let text = UITextView()
		text.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
		text.borderColor = UIColor.lightGray
		text.borderWidth = 1
		return text
	}()
	
	init(entry: ToDoEntry?) {
		self.entry = entry
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let desc = entry?.description {
			title = "Edit \(desc)"
		} else {
			title = "New entry"
		}
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
		
		view.addSubview(completed)
		view.addSubview(descriptionTextField)
		view.addSubview(notesTextField)
		self.view.backgroundColor = UIColor.white
		
		descriptionTextField.text = entry?.description
		notesTextField.text = entry?.notes
		
		updateViewConstraints()
	}
	
	func done() {
		guard let desc = descriptionTextField.text, desc.characters.count > 0 else { return }
		guard let entry = entry else {
			let newId = (appState.stateValue.state.toDoEntries.last?.id ?? 0) + 1
			appState.dispatch(AppAction.dismisEditEntryController)
			appState.dispatch(AppAction.addToDoEntry(ToDoEntry(id: newId, completed: completed.on, description: desc, notes: notesTextField.text)))
			return
		}
		
		let newEntry = ToDoEntry(id: entry.id, completed: completed.on, description: desc, notes: notesTextField.text)
		appState.dispatch(AppAction.dismisEditEntryController)
		appState.dispatch(AppAction.updateEntry(newEntry))
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		completed.snp.remakeConstraints { make in
			make.top.equalTo(view.snp.top).offset(20)
			make.leading.equalTo(view.snp.leading).offset(10)
		}
		
		descriptionTextField.snp.remakeConstraints { make in
			make.top.equalTo(completed.snp.bottom).offset(20)
			make.leading.equalTo(view.snp.leading).offset(10)
			make.trailing.equalTo(view.snp.trailing).offset(-10)
		}
		
		notesTextField.snp.remakeConstraints { make in
			make.top.equalTo(descriptionTextField.snp.bottom).offset(20)
			make.leading.equalTo(view.snp.leading).offset(10)
			make.trailing.equalTo(view.snp.trailing).offset(-10)
			make.bottom.equalTo(view.snp.bottom).offset(-10)
		}
	}
}
