//
//  SettingsReducer.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxSwift
import RxDataFlow

func settingsReducer(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
	switch action {
	case SettingsAction.showFrameworksController: return currentState.coordinator.handle(action)
	case SettingsAction.reloadTable: return .just( { $0 } )
	default: return .empty()
	}
}

