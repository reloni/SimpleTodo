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

	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
	}
}
