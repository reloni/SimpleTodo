//
//  Reducers.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 18.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift
import RxDataFlow

struct RootReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		print("handle new action: \(action.self)")
		switch action {
		case _ as SignInAction: return SignInReducer().handle(action, flowController: flowController)
		case _ as AppAction: return AppReducer().handle(action, flowController: flowController)
		case _ as GeneralAction:
			let flowController = flowController as! RxDataFlowController<AppState>
			return flowController.currentState.state.coordinator.handle(action, flowController: flowController)
		default: fatalError("Unknown action type")
		}
	}
}

struct AppReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		let currentState = flowController.currentState.state
		let action = action as! AppAction
		switch action {
		case .loadTasks: return ApplicationLogic.reloadTasks(currentState: currentState, fromRemote: true)
		case .addTask(let task): return ApplicationLogic.addTask(task: task, currentState: currentState)
		case .deleteTask(let index): return ApplicationLogic.deleteTask(currentState: currentState, entryId: index)
		case .reloadTasks: return ApplicationLogic.reloadTasks(currentState: currentState, fromRemote: false)
		case .showAllert(let controller, let error): return UICoordinator.showAlert(in: controller, with: error, currentState: currentState)
		case .showEditTaskController(let task): return UICoordinator.showEditEntryController(forTask: task, currentState: currentState)
		case .dismisEditTaskController: return UICoordinator.dismisEditEntryController(currentState: currentState)
		case .updateTask(let task): return ApplicationLogic.updateTask(task, currentState: currentState)
		case .completeTask(let index): return ApplicationLogic.updateTaskCompletionStatus(currentState: currentState, taskIndex: index)
		}
	}
}

struct SignInReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		let currentState = flowController.currentState.state
		switch action as? SignInAction {
		case .dismissFirebaseRegistration?: fallthrough
		case .showTasksListController?: fallthrough
		case .showFirebaseRegistration?: return currentState.coordinator.handle(action, flowController: flowController)
		case .logIn(let email, let password)?: return logIn(currentState: currentState, email: email, password: password)
		default: return .empty()
		}
	}
}
