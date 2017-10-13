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
		case .authenticated(let data): return data.1
		default: return nil
		}
	}
	
	var info: AuthenticationInfo? {
		guard case .authenticated(let data) = self else { return nil }
		return data.0
	}
}

struct AppState : RxStateType {
	let coordinator: ApplicationCoordinatorType
	let authentication: Authentication
	let uiApplication: UIApplication
	let authenticationService: AuthenticationServiceType
	let syncService: SynchronizationServiceType
	let repository: RepositoryType
	let syncStatus: SynchronizationStatus
	var badgeStyle: IconBadgeStyle { return UserDefaults.standard.iconBadgeStyle }
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
	         syncService: SynchronizationServiceType? = nil,
	         repository: RepositoryType? = nil) -> AppState {
		return AppState(coordinator: coordinator ?? state.coordinator,
		                authentication: authentication ?? state.authentication,
		                uiApplication: state.uiApplication,
		                authenticationService: state.authenticationService,
		                syncService: syncService ?? state.syncService,
		                repository: repository ?? state.repository,
		                syncStatus: syncStatus ?? state.syncStatus)
	}
}
