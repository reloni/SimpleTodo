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
		case PushNotificationsAction.disablePushNotificationsSubscription: return disablePushNotificationsSubscription(currentState: currentState)
		default: return .empty()
		}
	}
}

extension PushNotificationsReducer {
	func promtForPushNotifications(currentState state: AppState) -> Observable<RxStateType> {
		guard let user = state.authentication.user else { return .just(state) }
		
		OneSignal.promptForPushNotifications(userResponse: { accepted in
			print("User accepted notifications: \(accepted)")
			
			guard accepted else { return }
			
			OneSignal.setSubscription(true)
			OneSignal.sendTag("user_id", value: user.uid)
		})
		
		return .just(state)
	}
	
	func disablePushNotificationsSubscription(currentState state: AppState) -> Observable<RxStateType> {		
		OneSignal.deleteTag("user_id")
		OneSignal.setSubscription(false)
		
		return .just(state)
	}
}
