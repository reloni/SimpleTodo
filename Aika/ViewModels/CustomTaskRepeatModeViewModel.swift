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

final class CustomTaskRepeatModeViewModel: ViewModelType {
	let flowController: RxDataFlowController<AppState>
	
	let title = "Setup"
    
    let sectionsSubject: BehaviorSubject<[CustomTaskRepeatModeSection]> = {
        let section = CustomTaskRepeatModeSection(header: "Test 1", items: [
            CustomTaskRepeatModeSectionItem.placeholder(id: "placeholder"),
            CustomTaskRepeatModeSectionItem.patternType(id: "pattern", pattern: .day),
            CustomTaskRepeatModeSectionItem.repeatEvery(id: "repeat", value: 1)])
       return BehaviorSubject<[CustomTaskRepeatModeSection]>(value: [section])
    }()
    
    var sections: Observable<[CustomTaskRepeatModeSection]> { return sectionsSubject.asObservable().share(replay: 1, scope: SubjectLifetimeScope.whileConnected) }
	
//    lazy var sections: Observable<[CustomTaskRepeatModeSection]> = {
//        let section = CustomTaskRepeatModeSection(header: "Test", items: [CustomTaskRepeatModeSectionItem.patternType(.day),
//                                                                       CustomTaskRepeatModeSectionItem.repeatEvery(1)])
//        return .just([section])
//    }()

	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
	}
    
    func updateSections_1() {
        let section1 = CustomTaskRepeatModeSection(header: "Test 1", items: [
            CustomTaskRepeatModeSectionItem.placeholder(id: "placeholder"),
            CustomTaskRepeatModeSectionItem.patternType(id: "pattern", pattern: .week),
            CustomTaskRepeatModeSectionItem.repeatEvery(id: "repeat", value: 1),
            CustomTaskRepeatModeSectionItem.repeatEvery(id: "new", value: 2)])

        let section2 = CustomTaskRepeatModeSection(header: "Test 2", items: [
            CustomTaskRepeatModeSectionItem.placeholder(id: "placeholder 1"),
            CustomTaskRepeatModeSectionItem.patternType(id: "pattern 1", pattern: .week),
            CustomTaskRepeatModeSectionItem.repeatEvery(id: "repeat 1", value: 1),
            CustomTaskRepeatModeSectionItem.repeatEvery(id: "new 1", value: 2)])
        
        sectionsSubject.onNext([section1, section2])
    }
    
    func updateSections_2() {
        let section = CustomTaskRepeatModeSection(header: "Test 1", items: [CustomTaskRepeatModeSectionItem.placeholder(id: "placeholder"),
                                                                            CustomTaskRepeatModeSectionItem.patternType(id: "pattern", pattern: .year),
                                                                            CustomTaskRepeatModeSectionItem.repeatEvery(id: "repeat", value: 5)])
        sectionsSubject.onNext([section])
    }
}
