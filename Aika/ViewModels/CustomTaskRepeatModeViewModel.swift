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
        let section = CustomTaskRepeatModeSection(header: "Test", items: [CustomTaskRepeatModeSectionItem.patternType(.day),
                                                                          CustomTaskRepeatModeSectionItem.repeatEvery(1)])
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
    
    func updateSections() {
        let section = CustomTaskRepeatModeSection(header: "Test", items: [CustomTaskRepeatModeSectionItem.patternType(.day),
                                                                          CustomTaskRepeatModeSectionItem.repeatEvery(1),
                                                                          CustomTaskRepeatModeSectionItem.repeatEvery(2)])
        sectionsSubject.onNext([section])
    }
}
