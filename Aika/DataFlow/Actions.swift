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

enum SystemAction: RxActionType {
	var isSerial: Bool { return true }
	var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
	
	case clearKeychain
	case updateIconBadge
	case invoke(handler: () -> ())
	case setBadgeStyle(IconBadgeStyle)
    case setIncludeTime(Bool)
}

enum AnalyticalAction: RxActionType {
	var isSerial: Bool { return false }
	var scheduler: ImmediateSchedulerType? { return nil }
	
	enum LoginProvider: String {
		case password = "Login/password"
		case google = "Google"
		case facebook = "Facebook"
	}
	case logIn(LoginProvider)
	case logOff
	case deleteUser
	case deleteCache
	case addTask
	case editTask
	case deleteTask
	case completeTask
	case disablePushNotifications
	case enablePushNotifications
	case viewSourceCode
	case setBadgeStyle(IconBadgeStyle)
}

enum UIAction : RxActionType {
	var isSerial: Bool { return true }
	var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
	
	case showSettingsController
	case showRootController
	case showEditTaskController(Task?)
	case showFirebaseRegistrationController
	case showTasksListController
	case showTaskRepeatModeController(currentMode: TaskScheduler.Pattern?)
	case showTaskCustomRepeatModeController(currentMode: TaskScheduler.Pattern?)
	
	case dismissFirebaseRegistrationController
	case dismissSettingsController
	case dismisEditTaskController
	case dismissTaskRepeatModeController
	case dismissTaskCustomRepeatModeController
	
	case showSpinner
	case hideSpinner
	
	case showSnackView(error: Error, hideAfter: Double?)
	case showErrorMessage(Error)
	case showActionSheet(inController: WeakBox<UIViewController>, title: String?, message: String?, actions: [UIAlertAction], sourceView: UIView?)
    case showSafari(URL)
	
	case returnToRootController
}

enum AuthenticationAction : RxActionType {
	var isSerial: Bool { return true }
	var scheduler: ImmediateSchedulerType? {
		switch self {
		case .logIn: return MainScheduler.instance
		default: return nil
		}
	}

	case resetPassword(String)
	case refreshToken(force: Bool)
	case logOut
	case deleteUser
	case logIn(AuthenticationType)
	case register(String, String)
}

enum SettingsAction : RxActionType {
	var isSerial: Bool { return true }
	var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
	
	case showFrameworksController
	case reloadTable
}

enum EditTaskAction: RxActionType {
	var isSerial: Bool { return true }
	var scheduler: ImmediateSchedulerType? { return nil }
	
	case setRepeatMode(TaskScheduler.Pattern?)
    case setCustomRepeatMode(TaskScheduler.Pattern)
}

enum SynchronizationAction: RxActionType {
	var isSerial: Bool { return true }
	
	var scheduler: ImmediateSchedulerType? { return nil }
	
	case synchronize
	
	case addTask(Task)
	case updateTask(Task)
	case deleteTask(UUID)
	case completeTask(UUID)
	case reload
	
	case deleteCache
	case updateConfiguration
	case updateHost(String)
}

enum PushNotificationsAction : RxActionType {
	var isSerial: Bool { return true }
	var scheduler: ImmediateSchedulerType? { return MainScheduler.instance }
	
	case promptForPushNotifications
	case switchNotificationSubscription(subscribed: Bool)
}
