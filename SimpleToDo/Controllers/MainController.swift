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
}
