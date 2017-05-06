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
			switch $0.setBy {
			case EditTaskAction.addTask: fallthrough
			case TaskListAction.deleteTask: fallthrough
			case EditTaskAction.updateTask: fallthrough
			case TaskListAction.completeTask: fallthrough
			case TaskListAction.loadTasks: return true
			default: return false
			}
			}
			.flatMap { newState ->  Observable<[TaskSection]> in
				return Observable.just([TaskSection(header: "Tasks", items: newState.state.tasks)])
		}
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
		flowController.dispatch(RxCompositeAction(actions: [AuthenticationAction.refreshToken(force: false), TaskListAction.completeTask(index)]))
	}
	
	func editTask(index: Int) {
		flowController.dispatch(UIAction.showEditTaskController(flowController.currentState.state.tasks[index]))
	}
	
	func deleteTask(index: Int) {
		flowController.dispatch(RxCompositeAction(actions: [AuthenticationAction.refreshToken(force: false), TaskListAction.deleteTask(index)]))
	}
	
	func loadTasks() {
		flowController.dispatch(RxCompositeAction(actions: [AuthenticationAction.refreshToken(force: false), TaskListAction.loadTasks]))
	}
	
	func newTask() {
		flowController.dispatch(UIAction.showEditTaskController(nil))
	}
	
	func showSettings() {
		flowController.dispatch(UIAction.showSettingsController)
	}
}
