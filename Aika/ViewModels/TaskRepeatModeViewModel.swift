//
//  TaskRepeatModeViewModel.swift
//  Aika
//
//  Created by Anton Efimenko on 05.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow

final class TaskRepeatModeViewModel: ViewModelType {
	let flowController: RxDataFlowController<AppState>
	
	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
	}
}
