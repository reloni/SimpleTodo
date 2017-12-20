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

func pushNotificationsReducer(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
	switch action {
	case PushNotificationsAction.promptForPushNotifications: return promptForPushNotifications(currentState: currentState)
	case PushNotificationsAction.switchNotificationSubscription(let subscribed): return switchNotificationSubsctiption(currentState: currentState, subscribed: subscribed)
	default: return .empty()
	}
}

fileprivate func promptForPushNotifications(currentState state: AppState) -> Observable<RxStateMutator<AppState>> {
	guard let info = state.authentication.info else { return .just({ $0 }) }
	
	OneSignal.promptForPushNotifications(userResponse: { accepted in
		guard accepted else { return }
		
		enableSubscription(for: info)
	})
	
	return .just( { $0 } )
}

fileprivate func switchNotificationSubsctiption(currentState state: AppState, subscribed: Bool) -> Observable<RxStateMutator<AppState>> {
	if subscribed {
		return enablePushNotificationsSubscription(currentState: state)
	} else {
		return disablePushNotificationsSubscription()
	}
}

fileprivate func disablePushNotificationsSubscription() -> Observable<RxStateMutator<AppState>> {
	OneSignal.deleteTag("user_id")
	OneSignal.setSubscription(false)
	
	return .just( { $0 } )
}

fileprivate func enablePushNotificationsSubscription(currentState state: AppState)  -> Observable<RxStateMutator<AppState>> {
	guard let info = state.authentication.info else { return .just( { $0 } ) }
	
	enableSubscription(for: info)
	
	return .just( { $0 } )
}

fileprivate func enableSubscription(for info: AuthenticationInfo) {
	OneSignal.setSubscription(true)
	OneSignal.sendTag("user_id", value: info.uid)
}
