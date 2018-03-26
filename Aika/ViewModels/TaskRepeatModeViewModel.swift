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
    private let bag = DisposeBag()
	let flowController: RxDataFlowController<AppState>
	var currentPattern: TaskScheduler.Pattern?
	
	let title = "Repeat"
    
    private lazy var sectionsSubject: BehaviorSubject<[TaskRepeatModeSection]> = {
        return BehaviorSubject(value: self.createSections())
    }()
    
    var sections: Observable<[TaskRepeatModeSection]> {
        return sectionsSubject.asObservable()
    }
	
	init(flowController: RxDataFlowController<AppState>, currentPattern: TaskScheduler.Pattern?) {
		self.flowController = flowController
		self.currentPattern = currentPattern
        setupRx()
	}
    
    func setupRx() {
        flowController.state.do(onNext: { [weak self] state in
            guard let object = self else { return }
            if case EditTaskAction.setCustomRepeatMode(let pattern) = state.setBy {
                if case TaskScheduler.Pattern.byDay(let repeatEvery) = pattern, repeatEvery == 1 {
                    object.currentPattern = .daily
                    object.sectionsSubject.onNext(object.createSections())
                }
                
            }
        }).subscribe().disposed(by: bag)
    }
    
    private func createSections() -> [TaskRepeatModeSection] {
        let items = [TaskRepeatModeSectionItem(text: "Never", isSelected: self.currentPattern == nil, mode: nil, isCustom: false),
                     TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.daily.description, isSelected: self.currentPattern == .daily, mode: .daily, isCustom: false),
                     TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.weekly.description, isSelected: self.currentPattern == .weekly, mode: .weekly, isCustom: false),
                     TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.monthly.description, isSelected: self.currentPattern == .monthly, mode: .monthly, isCustom: false),
                     TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.yearly.description, isSelected: self.currentPattern == .yearly, mode: .yearly, isCustom: false)]
        let standardSection = TaskRepeatModeSection(header: "Header", items: items)
        let customSection = TaskRepeatModeSection(header: "Header",
                                                  items: [TaskRepeatModeSectionItem(text: "Custom", isSelected: false, mode: nil, isCustom: true)])
        return [standardSection, customSection]
    }
	
	func setNew(mode: TaskScheduler.Pattern?) {
		flowController.dispatch(UIAction.dismissTaskRepeatModeController)
		flowController.dispatch(EditTaskAction.setRepeatMode(mode))
	}
	
	func setCustomMode() {
		flowController.dispatch(UIAction.showTaskCustomRepeatModeController(currentMode: nil))
	}
}

