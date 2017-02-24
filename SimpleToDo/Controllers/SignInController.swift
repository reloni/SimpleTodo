//
//  SignInController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 20.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import SnapKit
import Material

final class SignInController : UIViewController {
//	let signInButton: GIDSignInButton = {
//		let button = GIDSignInButton()
//		return button
//	}()
	
	let loginButton: Button = {
		let button = Button()
		button.title = "Login"
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		view.addSubview(loginButton)
		
//		GIDSignIn.sharedInstance().clientID = "331164285591-6t6tsbbkv728o220ek2vilkc1er2u1rj.apps.googleusercontent.com"
//		GIDSignIn.sharedInstance().uiDelegate = self
//		GIDSignIn.sharedInstance().signIn()
		
		_ = loginButton.rx.tap.subscribe(onNext: { [weak self] in self?.login() })
		
		view.setNeedsUpdateConstraints()
		//updateViewConstraints()
	}
	
	func login() {
//		FIRAuth.auth()?.createUser(withEmail: "reloni@ya.ru", password: "Pass123", completion: { user, error in
//			print("user: \(user?.email)")
//			print("error: \(error)")
//		})
//		FIRAuth.auth()?.signIn(withEmail: "reloni@ya.ru", password: "Pass123", completion: { user, error in
//			print("user: \(user?.email)")
//			print("error: \(error)")
//			user?.getTokenForcingRefresh(true, completion: { result in
//				print("token: \(result.0)")
//				print("error: \(result.1)")
//				
//			})
//		})
		
		applicationStore.dispatch(AppAction.showFirebaseRegistration)
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		loginButton.snp.remakeConstraints { make in
			make.top.equalTo(view).offset(UIApplication.shared.statusBarFrame.height)
			make.leading.equalTo(view.snp.leading).offset(10)
			make.trailing.equalTo(view.snp.trailing).inset(10)
		}
	}
}

//extension SignInController : GIDSignInUIDelegate {
//	
//}
