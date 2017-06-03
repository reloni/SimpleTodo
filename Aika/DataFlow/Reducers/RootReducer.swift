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
	func handle(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
		#if DEBUG
			print("Handle action: \(action.self)")
		#endif
		
		switch action {
		case _ as AuthenticationAction: return AuthenticationReducer().handle(action, currentState: currentState)
		case _ as PushNotificationsAction: return PushNotificationsReducer().handle(action, currentState: currentState)
		case _ as SettingsAction: return SettingsReducer().handle(action, currentState: currentState)
		case _ as SynchronizationAction: return SynchronizationReducer().handle(action, currentState: currentState)
		case _ as SystemAction: return SystemReducer().handle(action, currentState: currentState)
		case _ as TasksAction: return TasksReducer().handle(action, currentState: currentState)
		case _ as UIAction: return currentState.coordinator.handle(action)
		default: fatalError("Unknown action type")
		}
	}
}
