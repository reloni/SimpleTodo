//
//  TaskRepeatModeViewModel.swift
//  Aika
//
//  Created by Anton Efimenko on 05.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

final class TaskRepeatModeViewModel: ViewModelType {
	let flowController: RxDataFlowController<AppState>
	let currentMode: TaskScheduler.Pattern?
	
	let title = "Title"
	
	lazy var sections: Observable<[TaskRepeatModeSection]> = {
		let items = [TaskRepeatModeSectionItem(text: "Test 1", isSelected: false),
		             TaskRepeatModeSectionItem(text: "Test 2", isSelected: true),
		             TaskRepeatModeSectionItem(text: "Test 3", isSelected: false)]
		
		return .just([TaskRepeatModeSection(header: "Header", items: items)])
	}()
	
	init(flowController: RxDataFlowController<AppState>, currentMode: TaskScheduler.Pattern?) {
		self.flowController = flowController
		self.currentMode = currentMode
	}
	
	func setNew(mode: TaskScheduler.Pattern) {
		flowController.dispatch(UIAction.dismissTaskRepeatModeController)
	}
}

