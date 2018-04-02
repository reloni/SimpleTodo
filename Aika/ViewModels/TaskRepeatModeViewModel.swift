//
//  TaskRepeatModeViewModel.swift
//  Aika
//
//  Created by Anton Efimenko on 05.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

private extension TaskScheduler.Pattern {
    var isCustom: Bool {
        switch self {
        case .byDay, .byMonthDays, .byWeek: return true
        default: return false
        }
    }
}

final class TaskRepeatModeViewModel: ViewModelType {
    private let bag = DisposeBag()
	let flowController: RxDataFlowController<AppState>
    let currentPatternSubject: BehaviorSubject<TaskScheduler.Pattern?>
    let initialPattern: TaskScheduler.Pattern?
	
	let title = "Repeat"
    
    let sectionsSubject: BehaviorSubject<[TaskRepeatModeSection]>
    
    var sections: Observable<[TaskRepeatModeSection]> {
        return sectionsSubject.asObservable()
    }
	
	init(flowController: RxDataFlowController<AppState>, currentPattern: TaskScheduler.Pattern?) {
		self.flowController = flowController
        self.currentPatternSubject = BehaviorSubject(value: currentPattern)
        self.initialPattern = currentPattern
        self.sectionsSubject = BehaviorSubject(value: TaskRepeatModeViewModel.createSections(pattern: currentPattern))
        setupRx()
	}
    
    func setupRx() {
        currentPatternSubject
            .skip(1)
            .map { TaskRepeatModeViewModel.createSections(pattern: $0) }
            .bind(to: sectionsSubject)
            .disposed(by: bag)
        

        flowController.state.do(onNext: { [weak self] state in
            guard let object = self else { return }
            guard case EditTaskAction.setCustomRepeatMode(let pattern) = state.setBy else { return }
            object.currentPatternSubject.onNext(pattern)
        }).subscribe().disposed(by: bag)
    }
	
	func setNew(mode: TaskScheduler.Pattern?) {
		flowController.dispatch(UIAction.dismissTaskRepeatModeController)
		flowController.dispatch(EditTaskAction.setRepeatMode(mode))
	}
    
    func close() {
        currentPatternSubject
            .take(1)
            .withLatestFrom(Observable.just(initialPattern)) { return ($0, $1) }
            .filter { $0.0 != $0.1 }
            .map { $0.0 }
            .withLatestFrom(Observable.just(flowController)) { return($0, $1) }
            .do(onNext: { current, flowController in
                flowController.dispatch(EditTaskAction.setRepeatMode(current))
            })
            .subscribe()
            .disposed(by: bag)
    }
	
	func setCustomMode() {
        currentPatternSubject
            .take(1)
            .withLatestFrom(Observable.just(flowController)) { ($0, $1) }
            .do(onNext: { $0.1.dispatch(UIAction.showTaskCustomRepeatModeController(currentMode: $0.0)) })
            .subscribe()
            .dispose()
	}
    
    private static func createSections(pattern: TaskScheduler.Pattern?) -> [TaskRepeatModeSection] {
        let items = [TaskRepeatModeSectionItem(text: "Never", isSelected: pattern == nil, mode: nil, isCustom: false),
                     TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.daily.description, isSelected: pattern == .daily, mode: .daily, isCustom: false),
                     TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.weekly.description, isSelected: pattern == .weekly, mode: .weekly, isCustom: false),
                     TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.biweekly.description, isSelected: pattern == .biweekly, mode: .biweekly, isCustom: false),
                     TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.monthly.description, isSelected: pattern == .monthly, mode: .monthly, isCustom: false),
                     TaskRepeatModeSectionItem(text: TaskScheduler.Pattern.yearly.description, isSelected: pattern == .yearly, mode: .yearly, isCustom: false)]
        let standardSection = TaskRepeatModeSection(header: "Header", items: items)
        
        let subtitleText = pattern?.isCustom == true ? pattern!.description : ""
        let customSection = TaskRepeatModeSection(header: "Header",
                                                  items: [TaskRepeatModeSectionItem(text: "Custom", isSelected: pattern?.isCustom == true, mode: pattern, isCustom: true),
                                                          TaskRepeatModeSectionItem(text: subtitleText, isSelected: false, mode: nil, isCustom: false, isSubtitle: true)])

        return [standardSection, customSection]
    }
}

