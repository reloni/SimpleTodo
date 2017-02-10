//
//  State.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 18.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import RxState
import RxSwift
import RxHttpClient
import Unbox
import UIKit
import Wrap
import UIKit

struct AppState : RxStateType {
	let rootController: MainController
	let logInInfo: LogInInfo?
	let httpClient: HttpClientType
	let tasks: [Task]
}

extension AppState {
	func new(tasks: [Task]) -> AppState {
		return AppState(rootController: rootController, logInInfo: logInInfo, httpClient: httpClient, tasks: tasks)
	}
}

enum AppAction : RxActionType {
	case reloadTasks([Task])
	case loadTasks
	case addTask(Task)
	case showEditTaskController(Task?)
	case dismisEditTaskController
	case deleteTask(Int)
	case showAllert(in: UIViewController, with: Error)
	case updateTask(Task)
	
	var work: RxActionWork {
		switch self {
		case .reloadTasks: return reloadEntriesActionWork(fromRemote: false)
		case .loadTasks: return reloadEntriesActionWork(fromRemote: true)
		case .deleteTask(let id): return deleteEntryActionWork(entryId: id)
		case .addTask(let task): return addEntryActionWork(task: task)
		case .showEditTaskController(let task): return showEditEntryControllerActionWork(task)
		case .dismisEditTaskController: return dismisEditEntryControllerActionWork()
		case .updateTask(let task): return updateEntryActionWork(task)
		case .showAllert(let controller, let error): return showAlertActionWork(in: controller, with: error)
		}
	}
}
