//
//  FirebaseRegistrationController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 24.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//


import UIKit
import SnapKit
import Material

final class FirebaseRegistrationController : UIViewController {
	let registrationButton: Button = {
		let button = Button()
		button.title = "Register"
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		view.addSubview(registrationButton)
		
		_ = registrationButton.rx.tap.subscribe(onNext: { [weak self] in self?.register() })
		
		view.setNeedsUpdateConstraints()
	}
	
	func register() {
		applicationStore.dispatch(AppAction.dismissFirebaseRegistration)
//		FIRAuth.auth()?.signIn(withEmail: "reloni@ya.ru", password: "Pass123", completion: { user, error in
//			print("user: \(user?.email)")
//			print("error: \(error)")
//			user?.getTokenForcingRefresh(true, completion: { result in
//				print("token: \(result.0)")
//				print("error: \(result.1)")
//				
//			})
//		})
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		registrationButton.snp.remakeConstraints { make in
			make.top.equalTo(view).offset(UIApplication.shared.statusBarFrame.height)
			make.leading.equalTo(view.snp.leading).offset(10)
			make.trailing.equalTo(view.snp.trailing).inset(10)
		}
	}
}
