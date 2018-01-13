//
//  TasksViewModel.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 19.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataSources
import RxDataFlow
import RxSwift

final class TasksViewModel: ViewModelType {
	let flowController: RxDataFlowController<AppState>
	
	let title = "Tasks"
	
	lazy var taskSections: Observable<[TaskSection]> = {
		return self.flowController.state.filter {
			switch ($0.setBy, $0.state.syncStatus) {
			case (SynchronizationAction.reload, _): fallthrough
			case (SynchronizationAction.addTask, _): fallthrough
			case (SynchronizationAction.deleteTask, _): fallthrough
			case (SynchronizationAction.updateTask, _): fallthrough
			case (SynchronizationAction.completeTask, _): return true
			case (SynchronizationAction.synchronize, SynchronizationStatus.failed): fallthrough
			case (SynchronizationAction.synchronize, SynchronizationStatus.completed): return true
			default: return false
			}
			}
			.flatMap { newState ->  Observable<[TaskSection]> in
				return Observable.just([TaskSection(header: "Tasks", items: newState.state.repository.tasks().map { $0.toStruct() })])
		}
			.startWith([TaskSection(header: "Tasks", items: self.flowController.currentState.state.repository.tasks().map { $0.toStruct() })])
			.subscribeOn(SerialDispatchQueueScheduler(qos: .utility))
	}()
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in self?.check(error: $0.error) })
	}()
	
	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
	}
	
	func completeTask(uuid: UUID) {
		flowController.dispatch(SynchronizationAction.completeTask(uuid))
		flowController.dispatch(RxCompositeAction.synchronizationAction)
		flowController.dispatch(AnalyticalAction.completeTask)
	}
	
	func editTask(uuid: UUID) {
		flowController.dispatch(UIAction.showEditTaskController(flowController.currentState.state.repository.task(for: uuid)!.toStruct()))
	}

	func deleteTask(forUuid uuid: UUID) {
		flowController.dispatch(SynchronizationAction.deleteTask(uuid))
		flowController.dispatch(RxCompositeAction.synchronizationAction)
		flowController.dispatch(AnalyticalAction.deleteTask)
	}
	
	func synchronize() {
		flowController.dispatch(RxCompositeAction.synchronizationAction)
	}
	
	func newTask() {
		flowController.dispatch(UIAction.showEditTaskController(nil))
	}
	
	func showSettings() {
		flowController.dispatch(UIAction.showSettingsController)
	}
}
