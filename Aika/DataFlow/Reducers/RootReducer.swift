//
//  RootReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 12.03.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow

func rootReducer(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
	#if DEBUG
		print("Handle action: \(action.self)")
	#endif
	
	switch action {
	case _ as AuthenticationAction: return authenticationReducer(action, currentState: currentState)
	case _ as PushNotificationsAction: return pushNotificationsReducer(action, currentState: currentState)
	case _ as SettingsAction: return settingsReducer(action, currentState: currentState)
	case _ as SynchronizationAction: return synchronizationReducer(action, currentState: currentState)
	case _ as SystemAction: return systemReducer(action, currentState: currentState)
	case _ as UIAction: return currentState.coordinator.handle(action)
	case _ as EditTaskAction: return .just({ $0 })
	case _ as AnalyticalAction:
        return .just({ $0 })
//        return analyticalReducer(action, currentState: currentState)
	default: fatalError("Unknown action type")
	}
}
