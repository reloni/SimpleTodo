//
//  EditTaskViewModel.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 15.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow

final class EditTaskViewModel {
	let flowController: RxDataFlowController<AppState>
	let task: Task?
	
	init(task: Task?, flowController: RxDataFlowController<AppState>) {
		self.task = task
		self.flowController = flowController
	}
	
	lazy var title: String = {
		if let desc = self.task?.description {
			return "Edit \(desc)"
		} else {
			return "New task"
		}
	}()
	
	func save(description: String, notes: String?) {
		guard description.characters.count > 0 else { return }
		
		guard let task = task else {
			let action = RxCompositeAction(actions: [EditTaskAction.dismisEditTaskController,
			                                         EditTaskAction.addTask(Task(uuid: UniqueIdentifier(),
			                                                                     completed: false,
			                                                                     description: description,
			                                                                     notes: notes,
			                                                                     targetDate: nil))])
			flowController.dispatch(action)
			return
		}
		
		let newTask = Task(uuid: task.uuid, completed: false, description: description, notes: notes, targetDate: nil)
		let action = RxCompositeAction(actions: [EditTaskAction.dismisEditTaskController,
		                                         EditTaskAction.updateTask(newTask)])
		flowController.dispatch(action)
	}
}
