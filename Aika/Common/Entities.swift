//
//  Entities.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 17.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Unbox
import RxDataSources
import RxSwift
import Wrap
import OneSignal
import UserNotificationsUI
import RealmSwift

struct AppConstants {
	static let baseUrl = "https://aika.cloud:443/api/v1"
//		static let baseUrl = "http://localhost:5000/api/v1"
	static let host = "aika.cloud"
	//	static let host = "dev.aika.cloud"
}

enum IconBadgeStyle: String {
	case overdue
	case today
	case all
}

enum AuthenticationError : Error {
	case signInError(Error)
	case registerError(Error)
	case tokenRevokedError(Error)
	case unknown
	case passwordResetError(Error)
	case notAuthorized
}

struct ServerSideError {
	let error: String
}

extension ServerSideError : Unboxable {
	init(unboxer: Unboxer) throws {
		self.error = try unboxer.unbox(key: "Error")
	}
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

struct UniqueIdentifier: UnboxableByTransform {
	typealias UnboxRawValue = String
	
	let uuid: UUID
	
	init?(identifierString: String) {
		if let id = UUID(uuidString: identifierString) {
			self.uuid = id
		} else {
			return nil
		}
	}
	
	init() {
		uuid = UUID()
	}
	
	static func transform(unboxedValue: String) -> UniqueIdentifier? {
		return UniqueIdentifier(identifierString: unboxedValue)
	}
}

extension UniqueIdentifier : Equatable {
	static func == (lhs: UniqueIdentifier, rhs: UniqueIdentifier) -> Bool {
		return lhs.uuid.uuidString == rhs.uuid.uuidString
	}
}

extension UniqueIdentifier : Hashable {
	var hashValue: Int { return uuid.hashValue }
}

extension UniqueIdentifier : CustomStringConvertible {
	var description: String { return uuid.uuidString }
}

extension UniqueIdentifier : WrapCustomizable {
	func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
		return uuid.uuidString
	}
}

struct BatchUpdate {
	let toCreate: [Task]
	let toUpdate: [Task]
	let toDelete: [UniqueIdentifier]
}

extension BatchUpdate: WrapCustomizable {
	func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
		var dict = [String: Any]()
		
		dict["toCreate"] = toCreate.map { $0.wrap(context: context, dateFormatter: dateFormatter) }
		dict["toUpdate"] = toUpdate.map { $0.wrap(context: context, dateFormatter: dateFormatter) }
		dict["toDelete"] = toDelete.map { $0.wrap(context: context, dateFormatter: dateFormatter) }
		
		return dict
	}
}
