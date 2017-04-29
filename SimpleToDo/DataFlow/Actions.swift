//
//  Actions.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 25.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift

enum UIAction : RxActionType {
	var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
	
	case showSettingsController
	case showRootController
	case showEditTaskController(Task?)
	case showFirebaseRegistrationController
	case showTasksListController
	
	
	case dismissFirebaseRegistrationController
	case dismissSettingsController
	case dismisEditTaskController
	
	case showError(Error)
	
	case returnToRootController
}

enum AuthenticationAction : RxActionType {
	var scheduler: ImmediateSchedulerType? { return nil }

	case resetPassword(String)
	case signOut
	case logIn(String, String)
	case register(String, String)
}

enum TaskListAction : RxActionType {
	var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }

	case loadTasks
	case deleteTask(Int)
	case completeTask(Int)
}

enum SettingsAction : RxActionType {
	var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
	
	case save
}

enum EditTaskAction : RxActionType {
	var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
	
	case addTask(Task)
	case updateTask(Task)
}

enum PushNotificationsAction : RxActionType {
	var scheduler: ImmediateSchedulerType? { return nil }
	
	case promtForPushNotifications
	case disablePushNotificationsSubscription
}
