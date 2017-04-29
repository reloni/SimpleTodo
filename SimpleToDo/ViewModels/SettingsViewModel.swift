//
//  SettingsViewModel.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

final class SettingsViewModel {
	let flowController: RxDataFlowController<AppState>
	
	let title = "Settings"
	
	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
	}
	
	func save() {
		
	}
	
	func close() {
		flowController.dispatch(SettingsAction.close)
	}
}
