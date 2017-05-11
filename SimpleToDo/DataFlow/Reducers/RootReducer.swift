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
		#if DEBUG
			print("Handle action: \(action.self)")
		#endif
		
		switch action {
		case _ as AuthenticationAction: return AuthenticationReducer().handle(action, flowController: flowController)
		case _ as PushNotificationsAction: return PushNotificationsReducer().handle(action, flowController: flowController)
		case _ as SettingsAction: return SettingsReducer().handle(action, flowController: flowController)
		case _ as SynchronizationAction: return SynchronizationReducer().handle(action, flowController: flowController)
		case _ as UIAction:
			let flowController = flowController as! RxDataFlowController<AppState>
			return flowController.currentState.state.coordinator.handle(action, flowController: flowController)
		default: fatalError("Unknown action type")
		}
	}
}
