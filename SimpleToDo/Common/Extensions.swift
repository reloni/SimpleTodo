//
//  Extensions.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 17.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import RxHttpClient
import Unbox
import UIKit
import RxSwift
import Material
import RxDataFlow

extension FileManager {
	var realmsDirectory: URL { return urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Realms") }
	
	func createOrUpdateRealmsDirectory() {
		guard !fileExists(atPath: realmsDirectory.path) else { return }
		
		try! createDirectory(at: realmsDirectory,
		                     withIntermediateDirectories: false,
		                     attributes: [FileAttributeKey.protectionKey.rawValue: FileProtectionType.completeUntilFirstUserAuthentication])
	}
}

extension RxCompositeAction {
	static var logOffActions: [RxActionType] {
		return [AuthenticationAction.signOut,
		        UIAction.returnToRootController,
		        PushNotificationsAction.switchNotificationSubscription(subscribed: false)]
	}
	
	static var refreshTokenAndSyncActions: [RxActionType] {
		return [AuthenticationAction.refreshToken(force: false),
						SynchronizationAction.synchronize]
	}
}

extension Notification {
	func keyboardHeight() -> CGFloat {
		return (userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
	}
	
	func statusBarFrame() -> CGRect {
		return userInfo?[UIApplicationStatusBarFrameUserInfoKey] as! CGRect
	}
}

extension TextField {
	static var base: TextField {
		let field = Theme.Controls.textField(withStyle: .body)
		field.isClearIconButtonEnabled = true
		return field
	}
}

extension TextView {	
	static var generic: TextView {
		let text = Theme.Controls.textView(withStyle: .body)
		
		text.placeholderActiveColor = Theme.Colors.blueberry
		text.placeholderNormalColor = Theme.Colors.romanSilver
		text.backgroundColor = Theme.Colors.white
		text.placeholderLabel.textColor = Theme.Colors.romanSilver
		text.borderColor = Theme.Colors.romanSilver
		text.borderWidth = 0.5
		text.isScrollEnabled = false
		
		return text
	}
}

extension Date {
	enum DateType {
		case today
		case yesterday
		case tomorrow
		case future
		case past
		case unknown
	}
	
	var type: DateType {
		if isToday {
			return .today
		} else if isTomorrow {
			return .tomorrow
		} else if isYesterday {
			return .yesterday
		} else if isBeforeYesterday {
			return .past
		} else if isAfterTomorrow {
			return .future
		}
		
		return .unknown
	}
	
	func setting(_ component: Calendar.Component, value: Int) -> Date {
		return Calendar.current.date(bySetting: component, value: value, of: self)!
	}
	
	func adding(_ component: Calendar.Component, value: Int) -> Date {
		return Calendar.current.date(byAdding: component, value: value, to: self)!
	}
	
	func beginningOfDay() -> Date {
		return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
	}
	
	var isInPast: Bool { return self < Date() }
	var isInFuture: Bool { return self < Date() }
	var isToday: Bool { return Calendar.current.isDateInToday(self) }
	var isTomorrow: Bool { return Calendar.current.isDateInTomorrow(self) }
	var isYesterday: Bool { return Calendar.current.isDateInYesterday(self) }
	
	var isBeforeYesterday: Bool {
		let yesterday = Date().adding(.day, value: -1).beginningOfDay()
		return self < yesterday
	}
	
	var isAfterTomorrow: Bool {
		let tomorrow = Date().adding(.day, value: 1).beginningOfDay()
		return self > tomorrow
	}
	
	static var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = .current
		return dateFormatter
	}()
	
	static var serverDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		//2017-01-05T21:55:57.001+00
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxx"
		return formatter
	}()
	
	func toServerDateString() -> String {
		return Date.serverDateFormatter.string(from: self)
	}
	
	func toSpelledDateString() -> String? {
		switch type {
		case .today: return "Today"
		case .yesterday: return "Yesterday"
		case .tomorrow: return "Tomorrow"
		default: return nil
		}
	}
	
	static func fromServer(string: String) -> Date? {
		return Date.serverDateFormatter.date(from: string)
	}
	
	func toString(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, withSpelling: Bool) -> String {
		let formatter = Date.dateFormatter
		
		if withSpelling, let spelled = toSpelledDateString() {
			guard timeStyle != .none else { return spelled }
			
			formatter.dateStyle = .none
			formatter.timeStyle = timeStyle
			return "\(spelled) \(formatter.string(from: self))"
		}
		
		formatter.dateStyle = dateStyle
		formatter.timeStyle = timeStyle
		
		return formatter.string(from: self)
	}
	
	func toDateString(withSpelling: Bool) -> String {
		return toString(dateStyle: .medium, timeStyle: .none, withSpelling: withSpelling)
	}
	
	func toDateAndTimeString(withSpelling: Bool) -> String {
		return toString(dateStyle: .medium, timeStyle: .short, withSpelling: withSpelling)
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
			return (try? unbox(data: data) as ServerSideError)?.error ?? "Internal server error"
		case AuthenticationError.signInError(let error): return error.localizedDescription
		case AuthenticationError.passwordResetError: return "Unable to send instructions to specified email adress"
		case AuthenticationError.registerError(let error): return error.localizedDescription
		case AuthenticationError.tokenRequestError(let error): return error.localizedDescription
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


extension HttpClient {
	static let baseUrl = "https://simpletaskmanager.net:443/api/v1"
//	static let baseUrl = "http://localhost:5000/api/v1"
}

extension Keychain {
	private static let keychain = Keychain()
	
	static var userEmail: String {
		get { return keychain.stringForAccount(account: "userEmail") ?? "" }
		set { keychain.setString(string: newValue, forAccount: "userEmail") }
	}
	
	static var userPassword: String {
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
	
	static var userUuid: String {
		get { return keychain.stringForAccount(account: "userUuid") ?? "" }
		set { keychain.setString(string: newValue, forAccount: "userUuid") }
	}
	
	static var deviceUuid: String {
		get {
			let uuid = keychain.stringForAccount(account: "deviceUuid") ?? ""
			
			guard uuid.characters.count == 0 else { return uuid }
			
			let newUuid = UUID().uuidString
			keychain.setString(string: newUuid, forAccount: "deviceUuid")
			
			return newUuid
		}
	}
}
