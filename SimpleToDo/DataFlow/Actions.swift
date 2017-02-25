//
//  Actions.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 25.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

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
