//
//  RootReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 12.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow

struct RootReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		print("handle new action: \(action.self)")
		switch action {
		case _ as SignInAction: return AuthenticationReducer().handle(action, flowController: flowController)
		case _ as TaskListAction: return TasksReducer().handle(action, flowController: flowController)
		case _ as EditTaskAction: return EditTaskReducer().handle(action, flowController: flowController)
		case _ as GeneralAction:
			let flowController = flowController as! RxDataFlowController<AppState>
			return flowController.currentState.state.coordinator.handle(action, flowController: flowController)
		default: fatalError("Unknown action type")
		}
	}
}
