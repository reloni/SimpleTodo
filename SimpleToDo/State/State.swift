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
	let rootController: MainController
	let logInInfo: LogInInfo?
	let httpClient: HttpClientType
	let tasks: [Task]
}

extension AppState {
	func new(tasks: [Task]) -> AppState {
		return AppState(coordinator: coordinator, rootController: rootController, logInInfo: logInInfo, httpClient: httpClient, tasks: tasks)
	}
	
	func new(coordinator: ApplicationCoordinatorType) -> AppState {
		return AppState(coordinator: coordinator, rootController: rootController, logInInfo: logInInfo, httpClient: httpClient, tasks: tasks)
	}
	
	func new(logInInfo: LogInInfo) -> AppState {
		return AppState(coordinator: coordinator, rootController: rootController, logInInfo: logInInfo, httpClient: httpClient, tasks: tasks)
	}
}

enum GeneralAction : RxActionType {
	var scheduler: ImmediateSchedulerType? {
		switch self {
		default: return MainScheduler.instance
		}
	}
	
	case showRootController
	case error(Error)
}

enum SignInAction : RxActionType {
	var scheduler: ImmediateSchedulerType? {
		switch self {
		case .showFirebaseRegistration: fallthrough
		case .dismissFirebaseRegistration: return MainScheduler.instance
		default: return nil
		}
	}

	case showFirebaseRegistration
	case dismissFirebaseRegistration
	case logIn(String, String)
}

enum AppAction : RxActionType {
	var scheduler: ImmediateSchedulerType? {
		switch self {
		case .showEditTaskController: fallthrough
		case .showAllert: fallthrough
		case .dismisEditTaskController: return MainScheduler.instance
		default: return nil
		}
	}
	
	case reloadTasks([Task])
	case loadTasks
	case addTask(Task)
	case showEditTaskController(Task?)
	case dismisEditTaskController
	case deleteTask(Int)
	case showAllert(in: UIViewController, with: Error)
	case updateTask(Task)
	case completeTask(Int)
}
