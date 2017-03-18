//
//  TasksListNavigationController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 01.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//


import UIKit
import SnapKit
import RxHttpClient
import AMScrollingNavbar

final class TasksListNavigationController : ScrollingNavigationController {
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor.white
		navigationBar.isTranslucent = false
	}
}
