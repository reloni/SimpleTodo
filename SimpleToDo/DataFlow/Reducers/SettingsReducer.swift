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
	func handle(_ action: RxActionType, flowController: RxDataFlowControllerType) -> Observable<RxStateType> {
		return handle(action, flowController: flowController as! RxDataFlowController<AppState>)
	}
	
	func handle(_ action: RxActionType, flowController: RxDataFlowController<AppState>) -> Observable<RxStateType> {
		switch action {
		case SettingsAction.showLogOffAlert: return flowController.currentState.state.coordinator.handle(action, flowController: flowController)
		default: return .empty()
		}
	}
}
