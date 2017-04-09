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
		let field = TextField()
		field.font = Theme.Fonts.main
		field.isClearIconButtonEnabled = true
		return field
	}
}

extension TextView {
	static var generic: TextView {
		let text = TextView()
		
		text.placeholderActiveColor = Theme.Colors.appleBlue
		text.placeholderNormalColor = Theme.Colors.lightGray
		text.backgroundColor = Theme.Colors.white
		text.placeholderLabel.font = Theme.Fonts.main
		text.placeholderLabel.textColor = Theme.Colors.lightGray
		text.font = Theme.Fonts.main
		text.borderColor = Theme.Colors.lightGray
		text.borderWidth = 0.5
		text.isScrollEnabled = false
		
		return text
	}
}

extension Date {
	public static var serverDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		//2017-01-05T21:55:57.001Z
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		return formatter
	}()
	
	public static var longDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy MM dd HH:mm"
		formatter.locale = Locale.current
		return formatter
	}()
	
	static func fromServer(string: String) -> Date? {
		return Date.serverDateFormatter.date(from: string)
	}
	
	var longDate: String {
		return Date.longDateFormatter.string(from: self)
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
