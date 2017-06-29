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

final class EditTaskViewModel2: ViewModelType {
	struct State: RxStateType {
		let description: String
		let notes: String?
		let targetDate: TaskDate?
		let datePickerExpanded: Bool
		let currentTask: Task?
		
		func new(description: String? = nil, notes: String? = nil, targetDate: TaskDate?? = nil, datePickerExpanded: Bool? = nil) -> State {
			return State(description: description ?? self.description,
			             notes: notes ?? self.notes,
			             targetDate: targetDate ?? self.targetDate,
			             datePickerExpanded: datePickerExpanded ?? self.datePickerExpanded,
			             currentTask: self.currentTask)
		}
	}
	
	struct EditTaskReducer : RxReducerType {
		func handle(_ action: RxActionType, currentState: State) -> Observable<RxStateMutator<State>> {
			guard let action = action as? EditTaskAction else { return .just { $0 } }
			
			switch action {
			case .datePickerExpanded(let e): return .just { $0.new(datePickerExpanded: e) }
			case .description(let d): return .just { $0.new(description: d) }
			case .notes(let n): return .just { $0.new(notes: n) }
			case .targetDate(let t): return .just { $0.new(targetDate: t) }
			}
		}
	}
	
	enum EditTaskAction: RxActionType {
		var isSerial: Bool { return true }
		var scheduler: ImmediateSchedulerType? { return nil }
		
		case description(String)
		case notes(String?)
		case targetDate(TaskDate?)
		case datePickerExpanded(Bool)
	}

	
	let flowController: RxDataFlowController<RootReducer>
	let localStateFlowController: RxDataFlowController<EditTaskReducer>
	let localStateSubject: BehaviorSubject<State>
	
	lazy var state: Observable<State> = { return self.localStateFlowController.state.map { $0.state } }()
	let bag = DisposeBag()
	
	init(task: Task?,
	     flowController: RxDataFlowController<RootReducer>,
	     taskDescription: Observable<String>,
	     taskNotes: Observable<String?>,
	     taskTargetDate: Observable<TaskDate?>,
	     datePickerExpanded: Observable<Bool>) {
		self.flowController = flowController
		
		let initialState = State(description: task?.description ?? "",
		                         notes: task?.notes ?? "", 
		                         targetDate: task?.targetDate, 
		                         datePickerExpanded: false, 
		                         currentTask: task)
		localStateSubject = BehaviorSubject(value: initialState)
		localStateFlowController = RxDataFlowController(reducer: EditTaskReducer(), initialState: initialState)
		
		let controllerObservable = Observable.just(localStateFlowController).share()
		
		taskDescription.withLatestFrom(controllerObservable) { return ($0.1, $0.0) }
			.do(onNext: { $0.0.dispatch(EditTaskAction.description($0.1)) })
			.subscribe()
			.disposed(by: bag)
		
		taskNotes.withLatestFrom(controllerObservable) { return ($0.1, $0.0) }
			.do(onNext: { $0.0.dispatch(EditTaskAction.notes($0.1)) })
			.subscribe()
			.disposed(by: bag)
		
		taskTargetDate.withLatestFrom(controllerObservable) { return ($0.1, $0.0) }
			.do(onNext: { $0.0.dispatch(EditTaskAction.targetDate($0.1)) })
			.subscribe()
			.disposed(by: bag)
		
		datePickerExpanded.withLatestFrom(controllerObservable) { return ($0.1, $0.0) }
			.do(onNext: { $0.0.dispatch(EditTaskAction.datePickerExpanded($0.1)) })
			.subscribe()
			.disposed(by: bag)
	}
	
	func switchDatePickerExpansion() {
		let isExpanded = !localStateFlowController.currentState.state.datePickerExpanded
		localStateFlowController.dispatch(EditTaskAction.datePickerExpanded(isExpanded))
	}
}

final class EditTaskViewModel: ViewModelType {
	struct State {
		let description: String
		let notes: String
		let targetDate: TaskDate?
		let datePickerExpanded: Bool
	}
	
	private let _datePickerExpanded = Variable(false)
	private let _taskTargetDateSubject = PublishSubject<TaskDate?>()
	
	let flowController: RxDataFlowController<RootReducer>
	let task: Task?
	
	lazy var taskDescription: Variable<String> = { return Variable<String>(self.task?.description ?? "") }()
	lazy var taskNotes: Variable<String?> = { return Variable<String?>(self.task?.notes) }()
	lazy var taskTargetDate: Variable<TaskDate?> = { return Variable<TaskDate?>(self.task?.targetDate) }()
	
	lazy var datePickerExpanded: Observable<Bool> = { self._datePickerExpanded.asObservable() }()
	lazy var taskTargetDateChanged: Observable<TaskDate?> = { self._taskTargetDateSubject.asObservable() }()
	
	init(task: Task?, flowController: RxDataFlowController<RootReducer>) {
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
	
	private func createTask() -> [RxActionType] {
		let action = RxCompositeAction(actions: [UIAction.dismisEditTaskController,
		                                         SynchronizationAction.addTask(Task(uuid: UniqueIdentifier(),
		                                                                            completed: false,
		                                                                            description: taskDescription.value,
		                                                                            notes: taskNotes.value,
		                                                                            targetDate: taskTargetDate.value))])
		
		return [action, RxCompositeAction.synchronizationAction]
	}
	
	private func update(task: Task) -> [RxActionType] {
		let newTask = Task(uuid: task.uuid, completed: false, description: taskDescription.value, notes: taskNotes.value, targetDate: taskTargetDate.value)
		let action = RxCompositeAction(actions: [UIAction.dismisEditTaskController,
		                                         SynchronizationAction.updateTask(newTask)])
		
		return [action, RxCompositeAction.synchronizationAction]
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
