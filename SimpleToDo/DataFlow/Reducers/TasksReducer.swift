//
//  TasksReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 12.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow
import RxHttpClient
import Unbox

struct TasksReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		let currentState = flowController.currentState.state
		switch action {
		case _ as EditTaskAction: return EditTaskReducer().handle(action, flowController: flowController)
		case TaskListAction.showEditTaskController: return currentState.coordinator.handle(action, flowController: flowController)
		case TaskListAction.loadTasks: return reloadTasks(currentState: currentState, fromRemote: true)
		case TaskListAction.deleteTask(let index): return deleteTask(currentState: currentState, index: index)
		case TaskListAction.completeTask(let index): return updateTaskCompletionStatus(currentState: currentState, index: index)
		default: return .empty()
		}
	}
}

extension TasksReducer {
	func reloadTasks(currentState state: AppState, fromRemote: Bool) -> Observable<RxStateType> {
		guard fromRemote else { return Observable.just(state) }
		
        return state.authentication.token.flatMapLatest { token -> Observable<RxStateType> in
            let headers = ["Authorization": "Bearer \(token)"]
            let request = URLRequest(url: URL(string: "\(HttpClient.baseUrl)/tasks/")!, headers: headers)
            
            return state.httpClient.requestData(request).flatMap { result -> Observable<RxStateType> in
                return .just(state.mutation.new(tasks: try unbox(data: result)))
            }
        }
	}
	
	func deleteTask(currentState state: AppState, index: Int) -> Observable<RxStateType> {        
        return state.authentication.token.flatMapLatest { token -> Observable<RxStateType> in
            let headers = ["Authorization": "Bearer \(token)"]
            let request = URLRequest(url: URL(string: "\(HttpClient.baseUrl)/tasks/\(state.tasks[index].uuid)")!, method: .delete, headers: headers)
            
            return state.httpClient.requestData(request).flatMap { _ -> Observable<RxStateType> in
                var currentEntries = state.tasks
                currentEntries.remove(at: index)
                return Observable.just(state.mutation.new(tasks: currentEntries))
            }
        }
	}
	
	func updateTaskCompletionStatus(currentState state: AppState, index: Int) -> Observable<RxStateType> {
        return state.authentication.token.flatMapLatest { token -> Observable<RxStateType> in
            let headers = ["Authorization": "Bearer \(token)"]
            let task = state.tasks[index]
            
            let url = URL(baseUrl: "\(HttpClient.baseUrl)/tasks/\(task.uuid)/ChangeCompletionStatus", parameters: ["completed":"\(!task.completed)"])!
            let request = URLRequest(url: url, method: .post, headers: headers)
            return state.httpClient.requestData(request).flatMap { _ -> Observable<RxStateType> in
                var currentTasks = state.tasks
                currentTasks.remove(at: index)
                return Observable.just(state.mutation.new(tasks: currentTasks))
            }
        }
	}
}
