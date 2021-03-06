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
        let includeTimeDefaultValue: Bool
		
		func new(description: String? = nil, notes: String? = nil, targetDate: TaskDate?? = nil, datePickerExpanded: Bool? = nil, repeatPattern: TaskScheduler.Pattern?? = nil) -> State {
			return State(description: description ?? self.description,
			             notes: notes ?? self.notes,
			             targetDate: targetDate ?? self.targetDate,
			             datePickerExpanded: datePickerExpanded ?? self.datePickerExpanded,
			             currentTask: self.currentTask,
			             repeatPattern: repeatPattern ?? self.repeatPattern,
                         includeTimeDefaultValue: includeTimeDefaultValue)
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
		                         repeatPattern: task?.prototype.repeatPattern,
                                 includeTimeDefaultValue: flowController.currentState.state.taskIncludeTime)
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
		let currentLocalState = localStateSubject.asObservable().share(replay: 1, scope: .forever)
		
		return [
			taskDescription.withLatestFrom(currentLocalState) { return ($1, $0) }
				.do(onNext: { [weak localStateSubject] in
					localStateSubject?.onNext($0.0.new(description: $0.1.trimmingCharacters(in: .whitespacesAndNewlines)))
				})
				.subscribe(),
			taskNotes.withLatestFrom(currentLocalState) { return ($1, $0) }
				.do(onNext: { [weak localStateSubject] in
					localStateSubject?.onNext($0.0.new(notes: $0.1))
				})
				.subscribe(),
			taskTargetDate.withLatestFrom(currentLocalState) { return ($1, $0) }
				.do(onNext: { [weak localStateSubject] in
					if $0.1 == nil {
						localStateSubject?.onNext($0.0.new(targetDate: $0.1, repeatPattern: Optional<TaskScheduler.Pattern?>.some(.none)))
					} else {
						localStateSubject?.onNext($0.0.new(targetDate: $0.1))
					}
				})
				.subscribe(),
			datePickerExpanded.withLatestFrom(currentLocalState) { return ($1, $0) }
				.do(onNext: { [weak localStateSubject] in
					if $0.1, $0.0.targetDate == nil {
                        localStateSubject?.onNext($0.0.new(targetDate: TaskDate(date: Date(), includeTime: $0.0.includeTimeDefaultValue), datePickerExpanded: $0.1))
					} else {
						localStateSubject?.onNext($0.0.new(datePickerExpanded: $0.1))
					}
				})
				.subscribe(),
			clearTargetDate.withLatestFrom(currentLocalState) { return ($1, $0) }
				.do(onNext: { [weak localStateSubject] in
					localStateSubject?.onNext($0.0.new(targetDate: Optional<TaskDate?>.some(Optional<TaskDate>.none), datePickerExpanded: false))
				})
				.subscribe(),
			saveChanges.withLatestFrom(currentLocalState) { return ($1, $0) }
				.do(onNext: { [weak self] in
					self?.save(state: $0.0)
				})
				.subscribe(),
			editRepeatMode.withLatestFrom(currentLocalState) { return ($1, $0) }
				.do(onNext: { [weak self] in
					self?.editRepeatMode(currentMode: $0.0.repeatPattern)
				})
				.subscribe(),
			// super ugly solution to handle changed repeat mode on other controller :(
			flowController.state.do(onNext: { [weak localStateSubject] state in
				guard let subject = localStateSubject else { return }
				if case EditTaskAction.setRepeatMode(let mode) = state.setBy {
					guard let current = try? subject.value() else { return }
					subject.onNext(current.new(repeatPattern: mode))
				}
			}).subscribe()
		]
	}
	
	func newTask(fromTask task: Task?, state: State) -> Task {
		return Task(uuid: task?.uuid ?? UUID(),
		            completed: false,
		            description: state.description,
		            notes: state.notes,
		            targetDate: state.targetDate,
					prototype: TaskPrototype(uuid: task?.prototype.uuid ?? UUID(), repeatPattern: state.repeatPattern))
	}
	
	private func createTask(state: State) -> [RxActionType] {
		let new = newTask(fromTask: nil, state: state)
		let action = RxCompositeAction(actions: [UIAction.dismisEditTaskController,
		                                         SynchronizationAction.addTask(new)])
		
		return [action, RxCompositeAction.synchronizationAction, AnalyticalAction.addTask]
	}
	
	private func update(task: Task, state: State) -> [RxActionType] {
		let new = newTask(fromTask: task, state: state)
		let action = RxCompositeAction(actions: [UIAction.dismisEditTaskController,
		                                         SynchronizationAction.updateTask(new)])
		
		return [action, RxCompositeAction.synchronizationAction, AnalyticalAction.editTask]
	}
	
	private func save(state: State) {
		guard state.description.count > 0 else { return }
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
