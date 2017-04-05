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
import AMScrollingNavbar

final class TasksListNavigationController : UINavigationController { //: ScrollingNavigationController {
	let bag = DisposeBag()
	
	let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationBar.setBackgroundImage(UIImage(), for: .default)
		navigationBar.isTranslucent = true

		NotificationCenter.default.rx.notification(NSNotification.Name.UIApplicationDidChangeStatusBarFrame)
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] notification in
				guard let object = self else { return }
				object.blurView.snp.updateConstraints {
					$0.height.equalTo(object.navigationBar.snp.height).offset(notification.statusBarFrame().height)
					$0.leading.equalTo(object.view.snp.leading)
					$0.trailing.equalTo(object.view.snp.trailing)
				}
			}).disposed(by: bag)

		view.insertSubview(blurView, belowSubview: navigationBar)
		
		blurView.snp.makeConstraints {
			$0.height.equalTo(navigationBar.snp.height).offset(UIApplication.shared.statusBarFrame.height)
			$0.leading.equalTo(view.snp.leading)
			$0.trailing.equalTo(view.snp.trailing)
		}
	}
}
