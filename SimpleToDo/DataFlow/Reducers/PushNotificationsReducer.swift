//
//  PushNotificationsReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 23.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift
import OneSignal
import RxDataFlow

struct PushNotificationsReducer : RxReducerType {
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		let currentState = flowController.currentState.state
		switch action {
		case PushNotificationsAction.promtForPushNotifications: return promtForPushNotifications(currentState: currentState)
		case PushNotificationsAction.switchNotificationSubscription(let subscribed): return switchNotificationSubsctiption(currentState: currentState, subscribed: subscribed)
		default: return .empty()
		}
	}
}

extension PushNotificationsReducer {
	func promtForPushNotifications(currentState state: AppState) -> Observable<RxStateType> {
		guard let info = state.authentication.info else { return .just(state) }
		
		OneSignal.promptForPushNotifications(userResponse: { accepted in
			guard accepted else { return }
			
			PushNotificationsReducer.enableSubscription(for: info)
		})
		
		return .just(state)
	}
	
	func switchNotificationSubsctiption(currentState state: AppState, subscribed: Bool) -> Observable<RxStateType> {
		if subscribed {
			return enablePushNotificationsSubscription(currentState: state)
		} else {
			return disablePushNotificationsSubscription(currentState: state)
		}
	}
	
	func disablePushNotificationsSubscription(currentState state: AppState) -> Observable<RxStateType> {		
		OneSignal.deleteTag("user_id")
		OneSignal.setSubscription(false)
		
		return .just(state)
	}
	
	func enablePushNotificationsSubscription(currentState state: AppState)  -> Observable<RxStateType> {
		guard let info = state.authentication.info else { return .just(state) }
		
		PushNotificationsReducer.enableSubscription(for: info)
		
		return .just(state)
	}
	
	static func enableSubscription(for info: AuthenticationInfo) {
		OneSignal.setSubscription(true)
		OneSignal.sendTag("user_id", value: info.uid)
	}
}
