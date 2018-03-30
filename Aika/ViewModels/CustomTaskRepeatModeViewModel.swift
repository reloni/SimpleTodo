//
//  CustomTaskRepeatModeViewModel.swift
//  Aika
//
//  Created by Anton Efimenko on 13.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxDataFlow
import RxSwift

protocol CustomTaskRepeatModeViewModelInputs {
    var patternType: PublishSubject<CustomRepeatPatternType> { get }
    var patternTypeSelected: PublishSubject<Bool> { get }
    var repeatEvery: PublishSubject<Int> { get }
    var repeatEverySelected: PublishSubject<Bool> { get }
    var save: PublishSubject<Void> { get }
}

protocol CustomTaskRepeatModeViewModelOutputs {
    var patternTypetems: Observable<[[CustomStringConvertible]]> { get }
    var repeatEveryItems: Observable<[[CustomStringConvertible]]> { get }
}

private extension CustomRepeatPatternType {
    var repeatEveryDisplayValue: String {
        switch self {
        case .day: return "Day(s)"
        case .month: return "Month(s)"
        case .week: return "Week(s)"
        case .year: return "Year(s)"
        }
    }
}

final class CustomTaskRepeatModeViewModel: ViewModelType {
    struct State {
        let pattern: CustomRepeatPatternType
        let patternExpanded: Bool
        let repeatEvery: Int
        let repeatEveryExpanded: Bool
        let selectedWeekdays: [TaskScheduler.DayOfWeek]
        
        private let calendar: Calendar
        
        var taskSchedulerPattern: TaskScheduler.Pattern {
            switch pattern {
            case .day: return .byDay(repeatEvery: UInt(repeatEvery))
            case .week: return .byWeek(repeatEvery: UInt(repeatEvery), weekDays: [])
            case .month: return .byMonthDays(repeatEvery: UInt(repeatEvery), days: [])
            case .year: fatalError("Not implemented")
            }
        }
        
        init(calendar: Calendar, pattern: TaskScheduler.Pattern?) {
            switch pattern {
            case .byDay(let repeatEvery)?:
                self.init(calendar: calendar, pattern: .day, selectedWeekdays: [], patternExpanded: false, repeatEvery: Int(repeatEvery), repeatEveryExpanded: false)
            case .byWeek(let repeatEvery, let weekDays)?:
                self.init(calendar: calendar, pattern: .week, selectedWeekdays: weekDays, patternExpanded: false, repeatEvery: Int(repeatEvery), repeatEveryExpanded: false)
            case .byMonthDays(let repeatEvery, let days)?:
                self.init(calendar: calendar, pattern: .month, selectedWeekdays: [], patternExpanded: false, repeatEvery: Int(repeatEvery), repeatEveryExpanded: false)
            default:
                self.init(calendar: calendar, pattern: .day, selectedWeekdays: [], patternExpanded: false, repeatEvery: 1, repeatEveryExpanded: false)
            }
        }
        
        init(calendar: Calendar, pattern: CustomRepeatPatternType, selectedWeekdays: [TaskScheduler.DayOfWeek], patternExpanded: Bool, repeatEvery: Int, repeatEveryExpanded: Bool) {
            self.calendar = calendar
            self.pattern = pattern
            self.selectedWeekdays = selectedWeekdays
            self.patternExpanded = patternExpanded
            self.repeatEvery = repeatEvery
            self.repeatEveryExpanded = repeatEveryExpanded
        }
        
        var sections: [CustomTaskRepeatModeSection] {
            return [basicSection(), weekdaysSection()].flatMap { $0 }
        }
        
        func basicSection() -> CustomTaskRepeatModeSection {
            let basicSectionItems = [
                CustomTaskRepeatModeSectionItem.placeholder(id: "BasicSectionPlaceholder"),
                CustomTaskRepeatModeSectionItem.patternType(pattern: pattern),
                patternExpanded ? CustomTaskRepeatModeSectionItem.patternTypePicker : nil,
                CustomTaskRepeatModeSectionItem.repeatEvery(value: repeatEvery),
                repeatEveryExpanded ? CustomTaskRepeatModeSectionItem.repeatEveryPicker : nil
                ].flatMap { $0 }
            return CustomTaskRepeatModeSection(header: "Basic setup", items: basicSectionItems)
        }
        
        func weekdaysSection() -> CustomTaskRepeatModeSection? {
            guard case CustomRepeatPatternType.week = pattern else { return nil }
            
            let items = calendar.weekdaySymbols
                .enumerated()
                .map { ($0.element, TaskScheduler.DayOfWeek(rawValue: $0.offset + 1)!) }
                .sorted { $0.1.numberInWeek(for: calendar) < $1.1.numberInWeek(for: calendar) }
                .map { CustomTaskRepeatModeSectionItem.weekday(name: $0.0.capitalized, value: $0.1, isSelected: false) }
            
            return CustomTaskRepeatModeSection(header: "Weekdays",
                                               items: [CustomTaskRepeatModeSectionItem.placeholder(id: "WeekdaysSectionPlaceholder")] + items)
        }
        
        func new(pattern: CustomRepeatPatternType? = nil, selectedWeekdays: [TaskScheduler.DayOfWeek]? = nil,
                 patternExpanded: Bool? = nil, repeatEvery: Int? = nil, repeatEveryExpanded: Bool? = nil) -> State {
            let newPatternExpanded: Bool = {
                guard let value = repeatEveryExpanded, value == true else { return patternExpanded ?? self.patternExpanded }
                return !value
            }()
            
            let newRepeatEveryExpanded: Bool = {
                guard let value = patternExpanded, value == true else { return repeatEveryExpanded ?? self.repeatEveryExpanded }
                return !value
            }()
            
            return State(calendar: calendar,
                         pattern: pattern ?? self.pattern,
                         selectedWeekdays: selectedWeekdays ?? self.selectedWeekdays,
                         patternExpanded: newPatternExpanded,
                         repeatEvery: repeatEvery ?? self.repeatEvery,
                         repeatEveryExpanded: newRepeatEveryExpanded)
        }
    }
    
	let flowController: RxDataFlowController<AppState>
    let bag = DisposeBag()

    // MARK: Inputs
    let patternType = PublishSubject<CustomRepeatPatternType>()
    let patternTypeSelected = PublishSubject<Bool>()
    let repeatEvery = PublishSubject<Int>()
    let repeatEverySelected = PublishSubject<Bool>()
    let save = PublishSubject<Void>()
	
	let title = "Setup"
    
    private let stateSubject: BehaviorSubject<State>
    var state: Observable<State> { return stateSubject.asObservable() }
    
    var sections: Observable<[CustomTaskRepeatModeSection]> {
        return stateSubject
            .asObservable()
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
            .map { $0.sections }
    }
    
    init(flowController: RxDataFlowController<AppState>, currentMode: TaskScheduler.Pattern?, calendar: Calendar) {
		self.flowController = flowController
        stateSubject = BehaviorSubject(value: State(calendar: calendar, pattern: currentMode))
        
        setupRx()
	}
    
    private func setupRx() {
        patternType
            .withLatestFrom(stateSubject) { return ($1, $0) }
            .map { $0.0.new(pattern: $0.1) }
            .bind(to: stateSubject)
            .disposed(by: bag)
        
        patternTypeSelected
            .withLatestFrom(stateSubject) { return ($1, $0) }
            .map { $0.0.new(patternExpanded: $0.1) }
            .bind(to: stateSubject)
            .disposed(by: bag)
        
        repeatEvery
            .withLatestFrom(stateSubject) { return $1.new(repeatEvery: $0) }
            .bind(to: stateSubject)
            .disposed(by: bag)
        
        repeatEverySelected
            .withLatestFrom(stateSubject) { return $1.new(repeatEveryExpanded: $0) }
            .bind(to: stateSubject)
            .disposed(by: bag)
        
        save.withLatestFrom(state) { $1.taskSchedulerPattern }
            .withLatestFrom(Observable.just(flowController)) { ($0, $1) }
            .do(onNext: { $0.1.dispatch(EditTaskAction.setCustomRepeatMode(CustomTaskRepeatModeViewModel.convertPattern($0.0))) })
            .subscribe()
            .disposed(by: bag)
    }
    
    static func convertPattern(_ value: TaskScheduler.Pattern) -> TaskScheduler.Pattern {
        switch value {
        case TaskScheduler.Pattern.byDay(let repeatEvery) where repeatEvery == 1: return TaskScheduler.Pattern.daily
        case TaskScheduler.Pattern.byDay(let repeatEvery) where repeatEvery == 7: return TaskScheduler.Pattern.weekly
        case TaskScheduler.Pattern.byDay(let repeatEvery) where repeatEvery == 14: return TaskScheduler.Pattern.biweekly
        default: return value
        }
    }
}

extension CustomTaskRepeatModeViewModel: CustomTaskRepeatModeViewModelInputs {
    var inputs: CustomTaskRepeatModeViewModelInputs { return self }
}

extension CustomTaskRepeatModeViewModel: CustomTaskRepeatModeViewModelOutputs {
    var outputs: CustomTaskRepeatModeViewModelOutputs { return self }
   
    var repeatEveryItems: Observable<[[CustomStringConvertible]]> {
        return state.asObservable().map { state in
            return [[Int](1...999), [state.pattern.repeatEveryDisplayValue]]
        }
    }
    
    var patternTypetems: Observable<[[CustomStringConvertible]]> {
        return Observable.just([[CustomRepeatPatternType.day,
                                 CustomRepeatPatternType.week,
                                 CustomRepeatPatternType.month]])
    }
}
