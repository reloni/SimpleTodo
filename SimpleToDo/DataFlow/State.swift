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

struct AppState : RxStateType {
	let coordinator: ApplicationCoordinatorType
	let rootController: TasksListNavigationController
	let logInInfo: LogInInfo?
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
		return AppState(coordinator: state.coordinator, rootController: state.rootController, logInInfo: state.logInInfo, httpClient: state.httpClient, tasks: tasks)
	}
	
	func new(coordinator: ApplicationCoordinatorType) -> AppState {
		return AppState(coordinator: coordinator, rootController: state.rootController, logInInfo: state.logInInfo, httpClient: state.httpClient, tasks: state.tasks)
	}
	
	func new(logInInfo: LogInInfo) -> AppState {
		return AppState(coordinator: state.coordinator, rootController: state.rootController, logInInfo: logInInfo, httpClient: state.httpClient, tasks: state.tasks)
	}
}
