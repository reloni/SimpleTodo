//
//  TasksListNavigationController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 01.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//


import UIKit
import SnapKit
import RxSwift
import Material

final class TasksListNavigationController : UINavigationController {
	let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
	
//	open override func prepare() {
//		super.prepare()
//		guard let v = navigationBar as? NavigationBar else {
//			return
//		}
//		
//		v.depthPreset = .none
//		v.dividerColor = Color.grey.lighten3
//	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationBar.setBackgroundImage(UIImage(), for: .default)
		navigationBar.isTranslucent = true
		
		view.insertSubview(blurView, belowSubview: navigationBar)
		
		blurView.snp.makeConstraints {
			$0.top.equalTo(view.snp.topMargin)
			$0.bottom.equalTo(navigationBar.snp.bottom)
			$0.leading.equalTo(view.snp.leading)
			$0.trailing.equalTo(view.snp.trailing)
		}
	}
}
