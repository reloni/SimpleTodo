//
//  SystemReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 18.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

struct SystemReducer : RxReducerType {
	func handle(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
		switch action as? SystemAction {
		case .updateIconBadge?:
			currentState.uiApplication.applicationIconBadgeNumber = currentState.syncService.overdueTasksCount()
			return .just({ $0 })
		case .invoke(let handler)?:
			handler()
			return .just({ $0 })
		default: return .empty()
		}
	}
}
