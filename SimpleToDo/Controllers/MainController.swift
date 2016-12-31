//
//  MainController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 01.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//


import UIKit
import SnapKit
import RxHttpClient

final class MainController : UINavigationController {
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor.white
		navigationBar.isTranslucent = false
	}
	
	func showError(error: Error) {
		guard case HttpClientError.invalidResponse(let response, _) = error else { print("unknown error"); return }
		print("http response code \(response.statusCode)")
		let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		present(alert, animated: true, completion: nil)
	}
	
	
}
