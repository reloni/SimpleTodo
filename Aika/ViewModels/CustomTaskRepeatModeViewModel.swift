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
        
        func new(pattern: CustomRepeatPatternType? = nil, patternExpanded: Bool? = nil) -> State {
            return State(pattern: pattern ?? self.pattern,
                         patternExpanded: patternExpanded ?? self.patternExpanded,
                         repeatEvery: self.repeatEvery,
                         repeatEveryExpanded: self.repeatEveryExpanded)
        }
    }
    
	let flowController: RxDataFlowController<AppState>
    let bag = DisposeBag()

    // MARK: Inputs
    let patternType = PublishSubject<CustomRepeatPatternType>()
    let patternTypeSelected = PublishSubject<Bool>()
	
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
        stateSubject = BehaviorSubject(value: State(pattern: .day, patternExpanded: false, repeatEvery: 1, repeatEveryExpanded: false))
        
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
    }
}

extension CustomTaskRepeatModeViewModel: CustomTaskRepeatModeViewModelInputs {
    var inputs: CustomTaskRepeatModeViewModelInputs { return self }
}
