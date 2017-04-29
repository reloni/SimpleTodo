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
	var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
	
	case showSettingsController
	case showRootController
	case returnToRootController
	case error(Error)
}

enum AuthenticationAction : RxActionType {
	var scheduler: ImmediateSchedulerType? {
		switch self {
		case .showTasksListController: fallthrough
		case .showFirebaseRegistration: fallthrough
		case .dismissFirebaseRegistration: return MainScheduler.instance
		default: return nil
		}
	}
	
	case resetPassword(String)
	case signOut
	case showFirebaseRegistration
	case dismissFirebaseRegistration
	case showTasksListController
	case logIn(String, String)
	case register(String, String)
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

enum SettingsAction : RxActionType {
	var scheduler: ImmediateSchedulerType? {
		switch self {
		case .close: return MainScheduler.instance
		default: return nil
		}
	}
	
	case save
	case close
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

enum PushNotificationsAction : RxActionType {
	var scheduler: ImmediateSchedulerType? { return nil }
	
	case promtForPushNotifications
	case disablePushNotificationsSubscription
}
