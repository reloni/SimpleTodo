//
//  Extensions.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 17.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import RxHttpClient
import UIKit
import RxSwift
import RxDataFlow

extension UIImage {
  func resize(toWidth w: CGFloat) -> UIImage? {
      return internalResize(toWidth: w)
  }
  
  private func internalResize(toWidth tw: CGFloat = 0, toHeight th: CGFloat = 0) -> UIImage? {
      var w: CGFloat?
      var h: CGFloat?
      
      if 0 < tw {
          h = size.height * tw / size.width
      } else if 0 < th {
          w = size.width * th / size.height
      }
      
      let g: UIImage?
      let t: CGRect = CGRect(x: 0, y: 0, width: w ?? tw, height: h ?? th)
      UIGraphicsBeginImageContextWithOptions(t.size, false, UIScreen.main.scale)
      draw(in: t, blendMode: .normal, alpha: 1)
      g = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return g
  }
}

extension UIWindow {
    func topMostViewController() -> UIViewController? {
        guard let rootViewController = self.rootViewController else { return nil }
        return topViewController(for: rootViewController)
    }
    
    func topViewController(for rootViewController: UIViewController?) -> UIViewController? {
        guard let rootViewController = rootViewController else { return nil }
        
        guard let presentedViewController = rootViewController.presentedViewController else { return rootViewController }
        
        switch presentedViewController {
        case let vc as UINavigationController: return topViewController(for: vc.viewControllers.last)
        case let vc as UITabBarController: return topViewController(for: vc.selectedViewController)
        default: return topViewController(for: presentedViewController)
        }
    }
    
}

extension RxDataFlowController {
    public func dispatchAfter(_ interval: DispatchTimeInterval, action: RxActionType) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + interval) {
            self.dispatch(action)
        }
    }
}

extension UIStoryboard {
	static let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil)
}

extension FileManager {
	var realmsDirectory: URL { return urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Realms") }
	
	func createOrUpdateRealmsDirectory() {
		guard !fileExists(atPath: realmsDirectory.path) else { return }
		
		try! createDirectory(at: realmsDirectory,
		                     withIntermediateDirectories: false,
		                     attributes: [FileAttributeKey(rawValue: FileAttributeKey.protectionKey.rawValue): FileProtectionType.completeUntilFirstUserAuthentication])
	}
}

extension RxCompositeAction {
	static var logOffActions: [RxActionType] {
		return [UIAction.showSpinner,
		        AuthenticationAction.logOut,
		        UIAction.returnToRootController,
		        PushNotificationsAction.switchNotificationSubscription(subscribed: false),
		        SynchronizationAction.updateConfiguration,
				AnalyticalAction.logOff,
		        UIAction.hideSpinner]
	}
	
	static var deleteUserActions: [RxActionType] {
		return [AuthenticationAction.deleteUser,
		        AuthenticationAction.logOut,
		        PushNotificationsAction.switchNotificationSubscription(subscribed: false),
		        SynchronizationAction.updateConfiguration,
		        SystemAction.clearKeychain,
				AnalyticalAction.deleteUser,
		        UIAction.returnToRootController]
	}
	
	static var refreshTokenAndSyncActions: [RxActionType] {
		return [AuthenticationAction.refreshToken(force: false),
						SynchronizationAction.synchronize]
	}
	
	static var synchronizationAction: RxCompositeAction {
		return RxCompositeAction(actions: refreshTokenAndSyncActions, isSerial: false)
	}
	
	static var deleteUserAction: RxCompositeAction {
		return RxCompositeAction(actions: deleteUserActions, isSerial: true)
	}
}

extension TaskScheduler.Pattern {
	var description: String {
		switch self {
		case .daily: return "Every day"
		case .weekly: return "Every week"
		case .biweekly: return "Every two weeks"
		case .monthly: return "Every month"
		case .yearly: return "Every year"
		case .byDay(let repeatEvery): return "Every \(repeatEvery) day(s)"
        case let .byWeek(repeatEvery, days): return "Every \(repeatEvery) week(s) at (\(days.map { $0.shortWeekdayPosix }.joined(separator: ", ")))"
		case let .byMonthDays(repeatEvery, _): return "Every \(repeatEvery) month(s)"
		}
	}
}

extension Notification {
	func keyboardHeight() -> CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
	}
}

extension UIScrollView {
	func updatecontentInsetFor(keyboardHeight: CGFloat) {
		contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: keyboardHeight + 25, right: contentInset.right)
	}
}

extension FileManager {
	var documentsDirectory: URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	}
}

extension Error {
	func isInvalidResponse() -> Bool {
		guard case HttpClientError.invalidResponse = self as Error else { return false }
		return true
	}
	
	func isTimedOut() -> Bool {
		return isUrlError(withCode: URLError.timedOut)
	}
	
	func isCannotConnectToHost() -> Bool {
		return isUrlError(withCode: URLError.cannotConnectToHost)
	}
	
	func isNotConnectedToInternet() -> Bool {
		return isUrlError(withCode: URLError.notConnectedToInternet)
	}
	
	func isUrlError(withCode code: URLError.Code) -> Bool {
		switch self as Error {
		case HttpClientError.clientSideError(let e) where ((e as? URLError)?.code == code) : return true
		case let urlError as URLError where urlError.code == code: return true
		default: return false
		}
	}
	
	func uiAlertMessage() -> String? {
		guard !self.isNotConnectedToInternet() else { return "Not connected to internet" }
		
		switch self as Error {
		case HttpClientError.clientSideError(let e): return e.localizedDescription
		case HttpClientError.invalidResponse(let response, let data):
			guard let data = data, data.count > 0 else {
				switch response.statusCode {
				case 404: return "Object not found"
				default: return "Internal server error"
				}
			}
			return (try? JSONDecoder().decode(ServerSideError.self, from: data))?.error ?? "Internal server error"
		case AuthenticationError.signInError(let error): return error.localizedDescription
		case AuthenticationError.passwordResetError: return "Unable to send instructions to specified email adress"
		case AuthenticationError.registerError(let error): return error.localizedDescription
		case AuthenticationError.tokenRevokedError: return "Error while refreshing access token"
		case AuthenticationError.notAuthorized: return "Unauthorized access"
		default: return "Unknown error"
		}
	}
}

extension UIFont {
	func new(sizeModifier: CGFloat) -> UIFont {
		return withSize(pointSize + sizeModifier)
	}
}

extension UserDefaults {
	var iconBadgeStyle: IconBadgeStyle {
		get {
			guard let style = IconBadgeStyle(rawValue: string(forKey: "iconBadgeStyle") ?? "") else {
				return .overdue
			}
			return style
		}
		set {
			set(newValue.rawValue, forKey: "iconBadgeStyle")
		}
	}
	
	var serverHost: String {
		get {
			return string(forKey: "serverHost") ?? AppConstants.host
		}
		set {
			set(newValue, forKey: "serverHost")
		}
	}
}

extension IconBadgeStyle {
	var description: String {
		switch self {
		case .all: return "All tasks"
		case .overdue: return "Overdue tasks"
		case .today: return "Today tasks"
		}
	}
}

extension Keychain {
	private static let keychain = Keychain()
	
	static var authenticationType: AuthenticationType? {
		get {
			guard let type = keychain.stringForAccount(account: "authenticationType") else { return nil }
			
			switch type {
			case "db": return AuthenticationType.db(email: userEmail, password: userPassword)
			case "facebook": return AuthenticationType.facebook
			case "google": return AuthenticationType.google
			default:return nil
			}
		}
		set {
			guard let type = newValue else {
				userEmail = ""
				userPassword = ""
				keychain.setString(string: "", forAccount: "authenticationType")
				return
			}
			
			switch type {
			case .facebook: keychain.setString(string: "facebook", forAccount: "authenticationType")
			case .google: keychain.setString(string: "google", forAccount: "authenticationType")
			case let .db(email, password):
				keychain.setString(string: "db", forAccount: "authenticationType")
				userEmail = email
				userPassword = password
			}
		}
	}
	
	private static var userEmail: String {
		get { return keychain.stringForAccount(account: "userEmail") ?? "" }
		set { keychain.setString(string: newValue, forAccount: "userEmail") }
	}
	
	private static var userPassword: String {
		get { return keychain.stringForAccount(account: "userPassword") ?? "" }
		set { keychain.setString(string: newValue, forAccount: "userPassword") }
	}
	
	static var token: String {
		get { return keychain.stringForAccount(account: "token") ?? "" }
		set { keychain.setString(string: newValue, forAccount: "token") }
	}
	
	static var refreshToken: String {
		get { return keychain.stringForAccount(account: "refreshToken") ?? "" }
		set { keychain.setString(string: newValue, forAccount: "refreshToken") }
	}
	
	static var tokenExpirationDate: Date {
		get { return Date.fromServer(string: keychain.stringForAccount(account: "tokenExpirationDate") ?? "") ?? Date() }
		set { keychain.setString(string: newValue.toServerDateString(), forAccount: "tokenExpirationDate") }
	}
	
	static var userUuid: String {
		get { return keychain.stringForAccount(account: "userUuid") ?? "" }
		set { keychain.setString(string: newValue, forAccount: "userUuid") }
	}
}

extension UIViewController {
	func createAlertContoller(withTitle title: String, message: String, actions: [UIAlertAction] = []) -> UIAlertController {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		actions.forEach { alert.addAction($0) }
		return alert
	}
}

extension Array {
    func removed(at index: Index) -> [Element] {
        var new = self
        new.remove(at: index)
        return new
    }
    
    func appended(_ newElement: Element) -> [Element] {
        var new = self
        new.append(newElement)
        return new
    }
}

extension Array where Element : Hashable {
	func distinct() -> [Element] {
		return Set(self).map { $0 }
	}
}

extension Dictionary where Key == String, Value == Any {
	func toJsonString() throws -> String? {
		return String(data: try JSONSerialization.data(withJSONObject: self, options: []), encoding: .utf8)
	}
	
	func toUint(_ key: String) -> UInt? {
		return UInt(exactly: self[key] as? Int ?? -1)
	}
}

extension String {
    func toJson() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
    }
}
