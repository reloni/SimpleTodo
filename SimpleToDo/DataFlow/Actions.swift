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
		case .showTasksListController: fallthrough
		case .showFirebaseRegistration: fallthrough
		case .dismissFirebaseRegistration: return MainScheduler.instance
		default: return nil
		}
	}
	
	case showFirebaseRegistration
	case dismissFirebaseRegistration
	case showTasksListController
	case logIn(String, String)
}

enum TaskListAction : RxActionType {
	var scheduler: ImmediateSchedulerType? {
		switch self {
		case .showEditTaskController: return MainScheduler.instance
		default: return nil
		}
	}
	
	case loadTasks
	case showEditTaskController(Task?)
	case deleteTask(Int)
	case completeTask(Int)
}

enum EditTaskAction : RxActionType {
	var scheduler: ImmediateSchedulerType? {
		switch self {
		case .dismisEditTaskController: return MainScheduler.instance
		default: return nil
		}
	}
	
	case addTask(Task)
	case updateTask(Task)
	case dismisEditTaskController
}