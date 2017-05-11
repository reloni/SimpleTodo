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
	var isToday: Bool { return Calendar.current.isDateInToday(self) }
	
	static var shortDateAndTime: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()
	
	static var serverDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		//2017-01-05T21:55:57.001+00
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxx"
		return formatter
	}()
	
	static var longDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy MM dd HH:mm"
		formatter.locale = Locale.current
		return formatter
	}()
	
	static func fromServer(string: String) -> Date? {
		return Date.serverDateFormatter.date(from: string)
	}
	
	var serverDate: String {
		return Date.serverDateFormatter.string(from: self)
	}
	
	var longDate: String {
		return Date.longDateFormatter.string(from: self)
	}
	
	var shortDateAndTime: String {
		return Date.shortDateAndTime.string(from: self)
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
	func isCannotConnectToHost() -> Bool {
		switch self as Error {
		case HttpClientError.clientSideError(let e) where ((e as? URLError)?.code == URLError.cannotConnectToHost) : return true
		case let urlError as URLError where urlError.code == URLError.cannotConnectToHost: return true
		default: return false
		}
	}
	
	func isNotConnectedToInternet() -> Bool {
		switch self as Error {
		case HttpClientError.clientSideError(let e) where ((e as? URLError)?.code == URLError.notConnectedToInternet) : return true
		case let urlError as URLError where urlError.code == URLError.notConnectedToInternet: return true
		default: return false
		}
	}
	
	func uiAlertMessage() -> String? {
		guard !self.isNotConnectedToInternet() else { return "Not connected to internet" }
		
		switch self as Error {
		case HttpClientError.clientSideError(let e):
			if let urlError = e as? URLError, urlError.code == URLError.notConnectedToInternet { return "Not connected to internet" }
			return e.localizedDescription
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
}
