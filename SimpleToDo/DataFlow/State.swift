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
    
    var token: Observable<String> {
        switch self {
        case .none: return .error(ApplicationError.notAuthenticated)
        case .user(let user): return user.token
        }
    }
}

struct AppState : RxStateType {
	let coordinator: ApplicationCoordinatorType
    let authentication: Authentication
	let httpClient: HttpClientType
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
		return AppState(coordinator: state.coordinator, authentication: state.authentication, httpClient: state.httpClient, tasks: tasks)
	}
	
	func new(coordinator: ApplicationCoordinatorType) -> AppState {
		return AppState(coordinator: coordinator, authentication: state.authentication, httpClient: state.httpClient, tasks: state.tasks)
	}
	
	func new(authentication: Authentication) -> AppState {
		return AppState(coordinator: state.coordinator, authentication: authentication, httpClient: state.httpClient, tasks: state.tasks)
	}
}
