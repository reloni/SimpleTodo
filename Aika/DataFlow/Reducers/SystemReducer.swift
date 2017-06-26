//
//  SystemReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 18.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit
import RxDataFlow
import RxSwift

struct SystemReducer : RxReducerType {
	func handle(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
		switch action as? SystemAction {
		case .updateIconBadge?:
			updateBadge(state: currentState)
			return .just({ $0 })
		case .invoke(let handler)?:
			handler()
			return .just({ $0 })
		case .clearKeychain?:
			clearKeychain()
			return .just({ $0 })
		case .setBadgeStyle(let style)?:
			UserDefaults.standard.iconBadgeStyle = style
			return .just({ $0 })
		default: return .empty()
		}
	}
	
	func updateBadge(state: AppState) {
		switch state.badgeStyle {
		case .all: state.uiApplication.applicationIconBadgeNumber = state.syncService.allTasksCount()
		case .overdue: state.uiApplication.applicationIconBadgeNumber = state.syncService.overdueTasksCount()
		case .today: state.uiApplication.applicationIconBadgeNumber = state.syncService.todayTasksCount()
		}
	}
	
	func clearKeychain() {
		Keychain.userEmail = ""
		Keychain.userPassword = ""
		Keychain.token = ""
		Keychain.refreshToken = ""
		Keychain.userUuid = ""
	}
}
