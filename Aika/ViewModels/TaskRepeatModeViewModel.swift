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
	
	let title = "Repeat"
	
	lazy var sections: Observable<[TaskRepeatModeSection]> = {
		let items = [TaskRepeatModeSectionItem(text: "Never", isSelected: self.currentMode == nil, mode: nil, isCustom: false),
		             TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.daily.description, isSelected: self.currentMode == .daily, mode: .daily, isCustom: false),
		             TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.weekly.description, isSelected: self.currentMode == .weekly, mode: .weekly, isCustom: false),
		             TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.monthly.description, isSelected: self.currentMode == .monthly, mode: .monthly, isCustom: false),
		             TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.yearly.description, isSelected: self.currentMode == .yearly, mode: .yearly, isCustom: false)]
		let standardSection = TaskRepeatModeSection(header: "Header", items: items)
		let customSection = TaskRepeatModeSection(header: "Header",
												  items: [TaskRepeatModeSectionItem(text: "Custom", isSelected: false, mode: nil, isCustom: true)])
		return .just([standardSection, customSection])
	}()
	
	init(flowController: RxDataFlowController<AppState>, currentMode: TaskScheduler.Pattern?) {
		self.flowController = flowController
		self.currentMode = currentMode
	}
	
	func setNew(mode: TaskScheduler.Pattern?) {
		flowController.dispatch(UIAction.dismissTaskRepeatModeController)
		flowController.dispatch(EditTaskAction.setRepeatMode(mode))
	}
	
	func setCustomMode() {
		flowController.dispatch(UIAction.showTaskCustomRepeatModeController(currentMode: nil))
	}
}

