//
//  FrameworksViewModel.swift
//  Aika
//
//  Created by Anton Efimenko on 07.06.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift
import RxDataSources

final class FrameworksViewModel: ViewModelType {
	let flowController: RxDataFlowController<RootReducer>
	
	let title = "Framoworks"
	
	lazy var sections: Observable<[FrameworksSection]> = {
		
		let frameworks = [FrameworkSectionItem(name: "test", url: URL(string: "https://google.com")!)]
		let section = FrameworksSection(header: "", items: frameworks)
			return .just([section])
	}()
	
	init(flowController: RxDataFlowController<RootReducer>) {
		self.flowController = flowController
	}
}
