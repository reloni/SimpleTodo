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

final class TasksViewModel {
	let flowController: RxDataFlowController<AppState>
	
	let title = "Tasks"
	
	lazy var taskSections: Observable<[TaskSection]> = {
		return self.flowController.state.filter {
			switch ($0.setBy, $0.state.syncStatus) {
			case (SynchronizationAction.addTask, _): fallthrough
			case (SynchronizationAction.deleteTask, _): fallthrough
			case (SynchronizationAction.updateTask, _): fallthrough
			case (SynchronizationAction.completeTask, _): return true
			case (SynchronizationAction.synchronize, SynchronizationStatus.completed): return true
			default: return false
			}
			}
			.flatMap { newState ->  Observable<[TaskSection]> in
				return Observable.just([TaskSection(header: "Tasks", items: newState.state.syncService.tasks().map { $0.toStruct() })])
		}
			.startWith([TaskSection(header: "Tasks", items: self.flowController.currentState.state.syncService.tasks().map { $0.toStruct() })])
			.subscribeOn(SerialDispatchQueueScheduler(qos: .utility))
	}()
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in
			guard let object = self else { return }
			if case AuthenticationError.notAuthorized = $0.error {
				RxCompositeAction.logOffActions.forEach { object.flowController.dispatch($0) }
				object.flowController.dispatch(UIAction.showErrorMessage($0.error))
			} else {
				object.flowController.dispatch(UIAction.showSnackView(error: $0.error, hideAfter: 4))
			}
		})
	}()
	
	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
	}
	
	func completeTask(index: Int) {
		flowController.dispatch(SynchronizationAction.completeTask(index))
		flowController.dispatch(RxCompositeAction(actions: RxCompositeAction.refreshTokenAndSyncActions))
	}
	
	func editTask(index: Int) {
		flowController.dispatch(UIAction.showEditTaskController(flowController.currentState.state.syncService.task(for: index).toStruct()))
	}
	
	func deleteTask(index: Int) {
		flowController.dispatch(SynchronizationAction.deleteTask(index))
		flowController.dispatch(RxCompositeAction(actions: RxCompositeAction.refreshTokenAndSyncActions))
	}
	
	func synchronize() {
		flowController.dispatch(RxCompositeAction(actions: RxCompositeAction.refreshTokenAndSyncActions))
	}
	
	func newTask() {
		flowController.dispatch(UIAction.showEditTaskController(nil))
	}
	
	func showSettings() {
		flowController.dispatch(UIAction.showSettingsController)
	}
}
