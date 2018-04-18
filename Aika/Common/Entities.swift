//
//  Entities.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 17.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import RxDataSources
import RxSwift
import OneSignal
import UserNotificationsUI
import RealmSwift

struct AppConstants {
    #if DEBUG
    static let baseUrl = "https://\(hostOverride ?? "\(AppConstants.host)")/api/v1"
    #else
    static let baseUrl = "https://\(AppConstants.host)/api/v1"
    #endif
	static let host = "aika.cloud"
    
    static var hostOverride: String? {
        guard let host = ProcessInfo.processInfo.environment["HOST_OVERRIDE"] else { return nil }
        return host.count > 0 ? host : nil
    }
	
	static var applicationType: String {
        
		switch UI_USER_INTERFACE_IDIOM() {
		case .pad: return "Aika for iPad"
		case .phone: return "Aika for iPhone"
		default: return "Aika for unknown device :)"
		}
	}
	
	static var applicationVersion: String {
		let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
		let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
		return "\(appVersion) (\(buildVersion))"
	}
	
	static var applicationDeviceInfo: String {
		return "\(applicationType) \(applicationVersion)"
	}
	
	static var isIPhoneX: Bool {
		return UIScreen.main.fixedCoordinateSpace.bounds.size.height == 812
	}
}

enum IconBadgeStyle: String {
	case overdue
	case today
	case all
}

enum CustomRepeatPatternType: String, CustomStringConvertible {
    case day = "Daily"
    case week = "Weekly"
    case month = "Monthly"
    case year = "Yearly"
    
    var description: String { return rawValue }
}

enum AuthenticationError : Error {
	case signInError(Error)
	case registerError(Error)
	case tokenRevokedError(Error)
	case unknown
	case passwordResetError(Error)
	case notAuthorized
}

struct ServerSideError: Decodable {
	let error: String
}

struct UserSettings {
	var pushNotificationsAllowed: Observable<Bool> {
		return Observable.create { observer in
			UNUserNotificationCenter.current().getNotificationSettings {
				observer.onNext($0.alertSetting.rawValue == 2)
				observer.onCompleted()
			}
			
			return Disposables.create()
		}
	}
	var pushNotificationsEnabled: Bool { return OneSignal.getPermissionSubscriptionState().subscriptionStatus.subscribed }
}

struct BatchUpdate: Encodable {
	let toCreate: [Task]
	let toUpdate: [Task]
	let toDelete: [UUID]
}
