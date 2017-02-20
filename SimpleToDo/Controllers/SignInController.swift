//
//  SignInController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 20.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import GoogleSignIn
import UIKit
import SnapKit

final class SignInController : UIViewController {
	let signInButton: GIDSignInButton = {
		let button = GIDSignInButton()
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		GIDSignIn.sharedInstance().clientID = "331164285591-6t6tsbbkv728o220ek2vilkc1er2u1rj.apps.googleusercontent.com"
		GIDSignIn.sharedInstance().uiDelegate = self
		GIDSignIn.sharedInstance().signIn()
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		signInButton.snp.remakeConstraints { make in
			make.top.equalTo(view.snp.topMargin)
			make.leading.equalTo(view.snp.leading).offset(10)
			make.trailing.equalTo(view.snp.trailing).inset(10)
		}
	}
}

extension SignInController : GIDSignInUIDelegate {
	
}
