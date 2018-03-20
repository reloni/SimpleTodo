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
        
        var sections: [CustomTaskRepeatModeSection] {
            let basicSectionItems = [
                CustomTaskRepeatModeSectionItem.placeholder(id: "placeholder"),
                CustomTaskRepeatModeSectionItem.patternType(pattern: pattern),
                patternExpanded ? CustomTaskRepeatModeSectionItem.patternTypePicker : nil,
                CustomTaskRepeatModeSectionItem.repeatEvery(value: repeatEvery),
                repeatEveryExpanded ? CustomTaskRepeatModeSectionItem.repeatEveryPicker : nil
                ].flatMap { $0 }
            let basicSection = CustomTaskRepeatModeSection(header: "Basic setup", items: basicSectionItems)
            return [basicSection]
        }
        
        func new(pattern: CustomRepeatPatternType? = nil, patternExpanded: Bool? = nil, repeatEvery: Int? = nil, repeatEveryExpanded: Bool? = nil) -> State {
            let newPatternExpanded: Bool = {
                guard let value = repeatEveryExpanded, value == true else { return patternExpanded ?? self.patternExpanded }
                return !value
            }()
            
            let newRepeatEveryExpanded: Bool = {
                guard let value = patternExpanded, value == true else { return repeatEveryExpanded ?? self.repeatEveryExpanded }
                return !value
            }()
            
            return State(pattern: pattern ?? self.pattern,
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
	
	let title = "Setup"
    
    private let stateSubject: BehaviorSubject<State>
    var state: Observable<State> { return stateSubject.asObservable() }
    
    var sections: Observable<[CustomTaskRepeatModeSection]> {
        return stateSubject
            .asObservable()
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
            .map { $0.sections }
    }
    
	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
        stateSubject = BehaviorSubject(value: State(pattern: .week, patternExpanded: false, repeatEvery: 1, repeatEveryExpanded: false))
        
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
