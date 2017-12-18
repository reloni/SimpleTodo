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
	let flowController: RxDataFlowController<AppState>
	static let frameworks = [FrameworkSectionItem(name: "RxSwift", url: URL(string: "https://github.com/ReactiveX/RxSwift")!),
	                         FrameworkSectionItem(name: "SnapKit", url: URL(string: "https://github.com/SnapKit/SnapKit")!),
	                         FrameworkSectionItem(name: "Material", url: URL(string: "https://github.com/CosmicMind/Material")!),
	                         FrameworkSectionItem(name: "RxHttpClient", url: URL(string: "https://github.com/RxSwiftCommunity/RxHttpClient")!),
	                         FrameworkSectionItem(name: "RxDataFlow", url: URL(string: "https://github.com/Reloni/RxDataFlow")!),
	                         FrameworkSectionItem(name: "RxDataSources", url: URL(string: "https://github.com/RxSwiftCommunity/RxDataSources")!),
	                         FrameworkSectionItem(name: "RxGesture", url: URL(string: "https://github.com/RxSwiftCommunity/RxGesture")!),
	                         FrameworkSectionItem(name: "OneSignal-iOS-SDK", url: URL(string: "https://github.com/OneSignal/OneSignal-iOS-SDK")!),
	                         FrameworkSectionItem(name: "Auth0.swift", url: URL(string: "https://github.com/auth0/Auth0.swift")!),
	                         FrameworkSectionItem(name: "JWTDecode.swift", url: URL(string: "https://github.com/auth0/JWTDecode.swift")!),
	                         FrameworkSectionItem(name: "realm-cocoa", url: URL(string: "https://github.com/realm/realm-cocoa")!)]
	
	let title = "Framoworks"
	
	lazy var sections: Observable<[FrameworksSection]> = {
		let section = FrameworksSection(header: "", items: FrameworksViewModel.frameworks)
			return .just([section])
	}()
	
	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
	}
}
