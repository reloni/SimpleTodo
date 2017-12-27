//
//  GenericNavigationController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

final class GenericNavigationController : UINavigationController {
//	let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		navigationBar.setBackgroundImage(UIImage(), for: .default)
//		navigationBar.isTranslucent = true
		navigationBar.tintColor = Theme.Colors.blueberry
		
//		view.insertSubview(blurView, belowSubview: navigationBar)
//
//		blurView.snp.makeConstraints {
//			$0.top.equalTo(view.snp.topMargin)
//			$0.bottom.equalTo(navigationBar.snp.bottom)
//			$0.leading.equalTo(view.snp.leading)
//			$0.trailing.equalTo(view.snp.trailing)
//		}
	}
	
	deinit {
		print("GenericNavigationController deinit")
	}
}
