//
//  Actions.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 25.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift
import UIKit

enum UIAction : RxActionType {
	var isSerial: Bool { return true }
	var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
	
	case showSettingsController
	case showRootController
	case showEditTaskController(Task?)
	case showFirebaseRegistrationController
	case showTasksListController
	
	
	case dismissFirebaseRegistrationController
	case dismissSettingsController
	case dismisEditTaskController
	
	case showSpinner
	case hideSpinner
	
	case showSnackView(error: Error, hideAfter: Double?)
	case showErrorMessage(Error)
	
	case returnToRootController
	
	case updateIconBadge
}

enum AuthenticationAction : RxActionType {
	var isSerial: Bool { return true }
	var scheduler: ImmediateSchedulerType? { return nil }

	case resetPassword(String)
	case refreshToken(force: Bool)
	case signOut
	case logIn(String, String)
	case register(String, String)
}

enum SettingsAction : RxActionType {
	var isSerial: Bool { return true }
	var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
	
	case showLogOffAlert(sourceView: UIView)
}

enum SynchronizationAction: RxActionType {
	var isSerial: Bool { return false }
	var scheduler: ImmediateSchedulerType? { return nil }
	
	case synchronize
	case addTask(Task)
	case updateTask(Task)
	case deleteTask(Int)
	case completeTask(Int)
	
	case updateConfiguration
}

enum PushNotificationsAction : RxActionType {
	var isSerial: Bool { return true }
	var scheduler: ImmediateSchedulerType? { return nil }
	
	case promtForPushNotifications
	case switchNotificationSubscription(subscribed: Bool)
}
