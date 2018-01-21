//
//  AnswersService.swift
//  Aika
//
//  Created by Anton Efimenko on 12.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import Crashlytics

struct AnswersService {
	static func sendEvent(for action: AnalyticalAction) {
		switch action {
		case .logIn(let type): Answers.logLogin(withMethod: type.rawValue, success: true, customAttributes: nil)
		case .logOff: Answers.logCustomEvent(withName: "Log off", customAttributes: nil)
		case .addTask: Answers.logCustomEvent(withName: "Add task", customAttributes: nil)
		case .deleteCache: Answers.logCustomEvent(withName: "Delete cache", customAttributes: nil)
		case .deleteTask: Answers.logCustomEvent(withName: "Delete task", customAttributes: nil)
		case .disablePushNotifications: Answers.logCustomEvent(withName: "Disable push notifications", customAttributes: nil)
		case .editTask: Answers.logCustomEvent(withName: "Edit task", customAttributes: nil)
		case .enablePushNotifications: Answers.logCustomEvent(withName: "Enable push notifications", customAttributes: nil)
		case .setBadgeStyle(let style): Answers.logCustomEvent(withName: "Set badge style", customAttributes: ["Style": style.description])
		case .viewSourceCode: Answers.logCustomEvent(withName: "View source code", customAttributes: nil)
		case .deleteUser: Answers.logCustomEvent(withName: "Delete user", customAttributes: nil)
		case .completeTask: Answers.logCustomEvent(withName: "Complete task", customAttributes: nil)
		}
	}
}
