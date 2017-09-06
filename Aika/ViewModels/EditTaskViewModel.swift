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
	struct State: RxStateType {
		let description: String
		let notes: String?
		let targetDate: TaskDate?
		let datePickerExpanded: Bool
		let currentTask: Task?
		let repeatPattern: TaskScheduler.Pattern?
		
		func new(description: String? = nil, notes: String? = nil, targetDate: TaskDate?? = nil, datePickerExpanded: Bool? = nil, repeatPattern: TaskScheduler.Pattern? = nil) -> State {
			return State(description: description ?? self.description,
			             notes: notes ?? self.notes,
			             targetDate: targetDate ?? self.targetDate,
			             datePickerExpanded: datePickerExpanded ?? self.datePickerExpanded,
			             currentTask: self.currentTask,
			             repeatPattern: repeatPattern ?? self.repeatPattern)
		}
	}
	
	let title: String
	
	let flowController: RxDataFlowController<AppState>

	let localStateSubject: BehaviorSubject<State>
	var state: Observable<State> { return localStateSubject.asObservable().observeOn(MainScheduler.instance) }
	
	init(task: Task?, flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
		
		let initialState = State(description: task?.description ?? "",
		                         notes: task?.notes ?? "", 
		                         targetDate: task?.targetDate, 
		                         datePickerExpanded: false, 
		                         currentTask: task,
		                         repeatPattern: .byWeek(repeatEvery: 2, weekDays: [.sunday]))
		localStateSubject = BehaviorSubject(value: initialState)

		title = {
			if let desc = task?.description {
				return "Edit \(desc)"
			} else {
				return "New task"
			}
		}()
	}
	
	func subscribe(taskDescription: Observable<String>,
	               taskNotes: Observable<String?>,
	               taskTargetDate: Observable<TaskDate?>,
	               datePickerExpanded: Observable<Bool>,
	               clearTargetDate: Observable<Void>,
	               saveChanges: Observable<Void>,
	               editRepeatMode: Observable<Void>) -> [Disposable] {
		let currentState = localStateSubject.asObservable().shareReplay(1)
		
		return [
			taskDescription.withLatestFrom(currentState) { return ($0.1, $0.0) }
				.do(onNext: { [weak localStateSubject] in localStateSubject?.onNext($0.0.new(description: $0.1.trimmingCharacters(in: .whitespacesAndNewlines))) })
				.subscribe(),
			taskNotes.withLatestFrom(currentState) { return ($0.1, $0.0) }
				.do(onNext: { [weak localStateSubject] in localStateSubject?.onNext($0.0.new(notes: $0.1)) })
				.subscribe(),
			taskTargetDate.withLatestFrom(currentState) { return ($0.1, $0.0) }
				.do(onNext: { [weak localStateSubject] in localStateSubject?.onNext($0.0.new(targetDate: $0.1)) })
				.subscribe(),
			datePickerExpanded.withLatestFrom(currentState) { return ($0.1, $0.0) }
				.do(onNext: { [weak localStateSubject] in
					if $0.1, $0.0.targetDate == nil {
						localStateSubject?.onNext($0.0.new(targetDate: TaskDate(date: Date(), includeTime: true), datePickerExpanded: $0.1))
					} else {
						localStateSubject?.onNext($0.0.new(datePickerExpanded: $0.1))
					}
				})
				.subscribe(),
			clearTargetDate.withLatestFrom(currentState) { return ($0.1, $0.0) }
				.do(onNext: { [weak localStateSubject] in
					localStateSubject?.onNext($0.0.new(targetDate: Optional<TaskDate?>.some(Optional<TaskDate>.none), datePickerExpanded: false))
				})
				.subscribe(),
			saveChanges.withLatestFrom(currentState) { return ($0.1, $0.0) }
				.do(onNext: { [weak self] in self?.save(state: $0.0) })
				.subscribe(),
			editRepeatMode.withLatestFrom(currentState) { return ($0.1, $0.0) }
				.do(onNext: { [weak self] in self?.editRepeatMode(currentMode: $0.0.repeatPattern) })
				.subscribe(),
			flowController.state.withLatestFrom(currentState) { return ($0.1, $0.0) }
				.do(onNext: { [weak localStateSubject] event in
					guard case EditTaskAction.setRepeatMode(let mode) = event.1.setBy else { return }
					localStateSubject?.onNext(event.0.new(repeatPattern: mode))
				}).subscribe()
		]
	}
	
	private func createTask(state: State) -> [RxActionType] {
		let action = RxCompositeAction(actions: [UIAction.dismisEditTaskController,
		                                         SynchronizationAction.addTask(Task(uuid: UniqueIdentifier(),
		                                                                            completed: false,
		                                                                            description: state.description,
		                                                                            notes: state.notes,
		                                                                            targetDate: state.targetDate))])
		
		return [action, RxCompositeAction.synchronizationAction]
	}
	
	private func update(task: Task, state: State) -> [RxActionType] {
		let newTask = Task(uuid: task.uuid, completed: false, description: state.description, notes: state.notes, targetDate: state.targetDate)
		let action = RxCompositeAction(actions: [UIAction.dismisEditTaskController,
		                                         SynchronizationAction.updateTask(newTask)])
		
		return [action, RxCompositeAction.synchronizationAction]
	}
	
	private func save(state: State) {
		guard state.description.characters.count > 0 else { return }
		guard let task = state.currentTask else {
			createTask(state: state).forEach { flowController.dispatch($0) }
			return
		}
		
		update(task: task, state: state).forEach { flowController.dispatch($0) }
	}
	
	func editRepeatMode(currentMode: TaskScheduler.Pattern?) {
		flowController.dispatch(UIAction.showTaskRepeatModeController(currentMode: currentMode))
	}
}
