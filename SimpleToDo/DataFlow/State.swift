//
//  State.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 18.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import RxDataFlow
import RxSwift
import RxHttpClient
import Unbox
import UIKit
import Wrap
import UIKit

enum Authentication {
	case none
	case authenticated(AuthenticationInfo, UserSettings)
	
	var tokenHeader: Observable<String> {
		switch self {
		case .none: return .error(AuthenticationError.notAuthorized)
		case .authenticated(let data): return .just(data.0.tokenHeader)
		}
	}
	
	var settings: UserSettings? {
		switch self {
		case .authenticated(let data): return data.1
		default: return nil
		}
	}
	
	var info: AuthenticationInfo? {
		guard case .authenticated(let data) = self else { return nil }
		return data.0
	}
}

struct AppState : RxStateType {
	let coordinator: ApplicationCoordinatorType
	let authentication: Authentication
	let webService: WebSerivce
	let tasks: [Task]
	let uiApplication: UIApplication
	let authenticationService: AuthenticationServiceType
	let repository: RepositoryType
	var overdueTasksCount: Int {
		let now = Date()
		return tasks.filter {
			guard let d = $0.targetDate?.date else { return false }
			return d <= now
			}.count
	}
}

struct AppStateMutation {
	let state: AppState
}

extension AppState {
	var mutation: AppStateMutation { return AppStateMutation(state: self) }
}

extension AppStateMutation {
	func new(tasks: [Task]? = nil, coordinator: ApplicationCoordinatorType? = nil, authentication: Authentication? = nil) -> AppState {
		return AppState(coordinator: coordinator ?? state.coordinator,
		                authentication: authentication ?? state.authentication,
		                webService: state.webService, 
		                tasks: tasks ?? state.tasks,
		                uiApplication: state.uiApplication,
		                authenticationService: state.authenticationService,
		                repository: state.repository)
	}
	
//	func new(with tasks: [Task]) -> AppState {
////		return AppState(coordinator: state.coordinator, authentication: state.authentication, webService: state.webService,
////		                tasks: tasks, uiApplication: state.uiApplication, authenticationService: state.authenticationService)
//		return new(tasks: tasks)
//	}
//	
//	func new(with coordinator: ApplicationCoordinatorType) -> AppState {
//		return new(coordinator: coordinator)
////		return AppState(coordinator: coordinator, authentication: state.authentication, webService: state.webService,
////		                tasks: state.tasks, uiApplication: state.uiApplication, authenticationService: state.authenticationService)
//	}
//	
//	func new(with authentication: Authentication) -> AppState {
//		return new(authentication: authentication)
////		return AppState(coordinator: state.coordinator, authentication: authentication, webService: state.webService,
////		                tasks: state.tasks, uiApplication: state.uiApplication, authenticationService: state.authenticationService)
//	}
}
