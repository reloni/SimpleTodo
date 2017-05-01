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
		text.placeholderNormalColor = Theme.Colors.slateGray
		text.backgroundColor = Theme.Colors.white
		text.placeholderLabel.textColor = Theme.Colors.slateGray
		text.borderColor = Theme.Colors.slateGray
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
	func uiAlertMessage() -> String? {
		switch self as Error {
		case HttpClientError.invalidResponse(let response, let data):
			guard let data = data, data.count > 0 else {
				switch response.statusCode {
				case 404: return "Object not found"
				default: return nil
				}
			}
			
			return (try? unbox(data: data) as ServerSideError)?.error
		case FirebaseError.signInError(let error): return error.localizedDescription
		case FirebaseError.passwordResetError: return "Unable to send instructions to specified email adress"
		case FirebaseError.registerError(let error): return error.localizedDescription
		case FirebaseError.tokenRequestError(let error): return error.localizedDescription
		default: return "Unknown error"
		}
	}
}

extension UIFont {
	func new(sizeModifier: CGFloat) -> UIFont {
		return withSize(pointSize + sizeModifier)
	}
}

extension FIRUser : LoginUser {
	var token: Observable<String> {
		return Observable.create { [weak self] observer in
			guard let object = self else { observer.onCompleted(); return Disposables.create() }
			
			object.getTokenForcingRefresh(false) { token, error in
				guard let token = token else {
					let err = error != nil ? FirebaseError.tokenRequestError(error!) : FirebaseError.unknown
					observer.onError(err)
					return
				}
				
				#if DEBUG
					print("token: \(token)")
				#endif
				
				observer.onNext(token)
				observer.onCompleted()
			}
			
			return Disposables.create() { observer.onCompleted() }
		}
	}
}

extension HttpClient {
	static let baseUrl = "https://simpletaskmanager.net:443/api/v1"
	//static let baseUrl = "http://localhost:5000/api/v1"
}

extension Keychain {
	private static let keychain = Keychain()
	
	static var userEmail: String {
		get { return keychain.stringForAccount(account: "userEmail") ?? "" }
		set { keychain.setString(string: newValue, forAccount: "userEmail", synchronizable: true, background: false) }
	}
	
	static var userPassword: String {
		get { return keychain.stringForAccount(account: "userPassword") ?? "" }
		set { keychain.setString(string: newValue, forAccount: "userPassword", synchronizable: true, background: false) }
	}
	
}
