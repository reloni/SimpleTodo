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

/*
github "CosmicMind/Material" == 2.6.3
github "RxSwiftCommunity/RxHttpClient" == 0.8.2
github "Reloni/RxDataFlow" == 0.8.0
github "RxSwiftCommunity/RxDataSources" == 1.0.3
github "JohnSundell/Unbox" == 2.4.0
github "JohnSundell/Wrap" == 2.1.1
github "RxSwiftCommunity/RxGesture" == 1.0.1
github "OneSignal/OneSignal-iOS-SDK" == 2.5.3
github "auth0/Auth0.swift" == 1.5.0
github "auth0/JWTDecode.swift" == 2.0.0
github "realm/realm-cocoa" == 2.7.0

*/

final class FrameworksViewModel: ViewModelType {
	let flowController: RxDataFlowController<RootReducer>
	static let frameworks = [FrameworkSectionItem(name: "RxSwift", url: URL(string: "https://github.com/ReactiveX/RxSwift")!),
	                         FrameworkSectionItem(name: "SnapKit", url: URL(string: "https://github.com/SnapKit/SnapKit")!),
	                         FrameworkSectionItem(name: "Material", url: URL(string: "https://github.com/CosmicMind/Material")!),
	                         FrameworkSectionItem(name: "RxHttpClient", url: URL(string: "https://github.com/RxSwiftCommunity/RxHttpClient")!),
	                         FrameworkSectionItem(name: "RxDataFlow", url: URL(string: "https://github.com/Reloni/RxDataFlow")!),
	                         FrameworkSectionItem(name: "RxDataSources", url: URL(string: "https://github.com/RxSwiftCommunity/RxDataSources")!),
	                         FrameworkSectionItem(name: "Unbox", url: URL(string: "https://github.com/JohnSundell/Unbox")!),
	                         FrameworkSectionItem(name: "Wrap", url: URL(string: "https://github.com/JohnSundell/Wrap")!),
	                         FrameworkSectionItem(name: "RxGesture", url: URL(string: "https://github.com/RxSwiftCommunity/RxGesture")!),
	                         FrameworkSectionItem(name: "OneSignal-iOS-SDK", url: URL(string: "https://github.com/OneSignal/OneSignal-iOS-SDK")!),
	                         FrameworkSectionItem(name: "Auth0.swift", url: URL(string: "https://github.com/auth0/Auth0.swift")!),
	                         FrameworkSectionItem(name: "JWTDecode.swift", url: URL(string: "https://github.com/auth0/JWTDecode.swift")!),
	                         FrameworkSectionItem(name: "realm-cocoa", url: URL(string: "https://github.com/realm/realm-cocoa")!)]
	
	let title = "Framoworks"
	
	lazy var sections: Observable<[FrameworksSection]> = {
		let section = FrameworksSection(header: "", items: frameworks)
			return .just([section])
	}()
	
	init(flowController: RxDataFlowController<RootReducer>) {
		self.flowController = flowController
	}
}
