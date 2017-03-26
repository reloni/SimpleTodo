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
	case user(LoginUser)
	
	var tokenHeader: Observable<String> {
		switch self {
		case .none: return .error(ApplicationError.notAuthenticated)
		case .user(let user): return user.tokenHeader
		}
	}
}

struct AppState : RxStateType {
	let coordinator: ApplicationCoordinatorType
	let authentication: Authentication
	let webService: WebSerivce
	let tasks: [Task]
}

struct AppStateMutation {
	let state: AppState
}

extension AppState {
	var mutation: AppStateMutation { return AppStateMutation(state: self) }
}

extension AppStateMutation {
	func new(tasks: [Task]) -> AppState {
		return AppState(coordinator: state.coordinator, authentication: state.authentication, webService: state.webService, tasks: tasks)
	}
	
	func new(coordinator: ApplicationCoordinatorType) -> AppState {
		return AppState(coordinator: coordinator, authentication: state.authentication, webService: state.webService, tasks: state.tasks)
	}
	
	func new(authentication: Authentication) -> AppState {
		return AppState(coordinator: state.coordinator, authentication: authentication, webService: state.webService, tasks: state.tasks)
	}
}
