//
//  SettingsReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow


struct SettingsReducer : RxReducerType {
	func handle(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
		switch action {
		case SettingsAction.showFrameworksController: return currentState.coordinator.handle(action)
		default: return .empty()
		}
	}
}
