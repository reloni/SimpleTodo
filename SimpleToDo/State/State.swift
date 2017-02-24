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
}

enum AppAction : RxActionType {
	var scheduler: ImmediateSchedulerType? {
		switch self {
		case .showEditTaskController: fallthrough
		case .showAllert: fallthrough
		case .showRootController: fallthrough
		case .dismisEditTaskController: return MainScheduler.instance
		default: return nil
		}
	}
	
	case showRootController
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
