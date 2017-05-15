//
//  EditTaskViewModel.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 15.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift
import RxDataFlow

final class EditTaskViewModel: ViewModelType {
	private let _datePickerExpanded = Variable(false)
	private let _taskTargetDateSubject = PublishSubject<TaskDate?>()
	
	let flowController: RxDataFlowController<AppState>
	let task: Task?
	
	lazy var taskDescription: Variable<String> = { return Variable<String>(self.task?.description ?? "") }()
	lazy var taskNotes: Variable<String?> = { return Variable<String?>(self.task?.notes) }()
	lazy var taskTargetDate: Variable<TaskDate?> = { return Variable<TaskDate?>(self.task?.targetDate) }()
	
	lazy var datePickerExpanded: Observable<Bool> = { self._datePickerExpanded.asObservable() }()
	lazy var taskTargetDateChanged: Observable<TaskDate?> = { self._taskTargetDateSubject.asObservable() }()
	
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
	
	func clearTargetDate() {
		_taskTargetDateSubject.onNext(nil)
		_datePickerExpanded.value = false
	}
	
	func switchDatePickerExpansion() {
		_datePickerExpanded.value = !_datePickerExpanded.value
		if _datePickerExpanded.value, taskTargetDate.value == nil {
			_taskTargetDateSubject.onNext(TaskDate(date: Date(), includeTime: true))
		}
	}
	
	private func  createTask() -> [RxActionType] {
		let action = RxCompositeAction(actions: [UIAction.dismisEditTaskController,
		                                         SynchronizationAction.addTask(Task(uuid: UniqueIdentifier(),
		                                                                            completed: false,
		                                                                            description: taskDescription.value,
		                                                                            notes: taskNotes.value,
		                                                                            targetDate: taskTargetDate.value))])
		
		return [action, RxCompositeAction(actions: RxCompositeAction.refreshTokenAndSyncActions)]
	}
	
	private func update(task: Task) -> [RxActionType] {
		let newTask = Task(uuid: task.uuid, completed: false, description: taskDescription.value, notes: taskNotes.value, targetDate: taskTargetDate.value)
		let action = RxCompositeAction(actions: [UIAction.dismisEditTaskController,
		                                         SynchronizationAction.updateTask(newTask)])
		
		return [action, RxCompositeAction(actions: RxCompositeAction.refreshTokenAndSyncActions)]
	}
	
	func save() {
		guard taskDescription.value.characters.count > 0 else { return }
		guard let task = task else {
			createTask().forEach { flowController.dispatch($0) }
			return
		}
		
		update(task: task).forEach { flowController.dispatch($0) }
	}
}
