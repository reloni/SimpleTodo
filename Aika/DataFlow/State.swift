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
import UIKit
import UIKit

enum SynchronizationStatus {
	case completed
	case failed(Error)
	case inProgress
}

enum Authentication {
	case none
	case authenticated(AuthenticationInfo, UserSettings)
	
	var settings: UserSettings? {
		switch self {
        case let .authenticated(_, userSettings): return userSettings
		default: return nil
		}
	}
	
	var info: AuthenticationInfo? {
		guard case let .authenticated(info, _) = self else { return nil }
		return info
	}
}

struct AppState : RxStateType {
	let coordinator: ApplicationCoordinatorType
	let authentication: Authentication
	let uiApplication: UIApplication
	let authenticationService: AuthenticationServiceType
	let webService: WebServiceType
	let repository: RepositoryType
	let syncStatus: SynchronizationStatus
	var badgeStyle: IconBadgeStyle { UserDefaults.standard.iconBadgeStyle }
    var taskIncludeTime: Bool { UserDefaults.standard.taskIncludeTime }
}

struct AppStateMutation {
	let state: AppState
}

extension AppState {
	var mutation: AppStateMutation { return AppStateMutation(state: self) }
}

extension AppStateMutation {
	func new(coordinator: ApplicationCoordinatorType? = nil,
	         authentication: Authentication? = nil,
	         syncStatus: SynchronizationStatus? = nil,
	         webService: WebServiceType? = nil,
	         repository: RepositoryType? = nil) -> AppState {
		return AppState(coordinator: coordinator ?? state.coordinator,
		                authentication: authentication ?? state.authentication,
		                uiApplication: state.uiApplication,
		                authenticationService: state.authenticationService,
		                webService: webService ?? state.webService,
		                repository: repository ?? state.repository,
		                syncStatus: syncStatus ?? state.syncStatus)
	}
}
