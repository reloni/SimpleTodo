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
	case user(LoginUser, UserSettings)
	
	var tokenHeader: Observable<String> {
		switch self {
		case .none: return .error(ApplicationError.notAuthenticated)
		case .user(let user, _): return user.tokenHeader
		}
	}
	
	var user: LoginUser? {
		guard case .user(let u, _) = self else { return nil }
		return u
	}
	
	var settings: UserSettings? {
		guard case .user(_, let s) = self else { return nil }
		return s
	}
}

struct AppState : RxStateType {
	let coordinator: ApplicationCoordinatorType
	let authentication: Authentication
	let webService: WebSerivce
	let tasks: [Task]
	let uiApplication: UIApplication
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
	func new(tasks: [Task]) -> AppState {
		return AppState(coordinator: state.coordinator, authentication: state.authentication, webService: state.webService, tasks: tasks, uiApplication: state.uiApplication)
	}
	
	func new(coordinator: ApplicationCoordinatorType) -> AppState {
		return AppState(coordinator: coordinator, authentication: state.authentication, webService: state.webService, tasks: state.tasks, uiApplication: state.uiApplication)
	}
	
	func new(authentication: Authentication) -> AppState {
		return AppState(coordinator: state.coordinator, authentication: authentication, webService: state.webService, tasks: state.tasks, uiApplication: state.uiApplication)
	}
}
