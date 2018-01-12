//
//  AnalyticalReducer.swift
//  Aika
//
//  Created by Anton Efimenko on 12.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import RxSwift
import RxDataFlow

func analyticalReducer(_ action: RxActionType, currentState: AppState) -> Observable<RxStateMutator<AppState>> {
	guard let action = action as? AnalyticalAction else { return .empty() }
	
	AnswersService.sendEvent(for: action)	
	return .empty()
}
