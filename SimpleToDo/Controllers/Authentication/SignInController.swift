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
	let emailTextField: TextField = {
		let field = TextField()
		field.font = Theme.Fonts.main
		field.placeholder = "Email"
		field.detail = "Enter your email"
		field.keyboardType = .emailAddress
		field.autocapitalizationType = .none
		field.returnKeyType = .next
		field.isClearIconButtonEnabled = true
		return field
	}()
	
	let passwordTextField: TextField = {
		let field = TextField()
		field.placeholder = "Password"
		field.detail = "Enter your password"
		field.isSecureTextEntry = true
		field.keyboardType = .default
		field.returnKeyType = .done
		field.isClearIconButtonEnabled = true
		return field
	}()
	
	let loginButton: Button = {
		let button = Button()
		button.title = "Login"
		button.backgroundColor = Theme.Colors.appleBlue
		button.titleColor = UIColor.white
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		view.addSubview(loginButton)
		view.addSubview(emailTextField)
		view.addSubview(passwordTextField)
		
		_ = loginButton.rx.tap.subscribe(onNext: { [weak self] in self?.login() })
		
		loginButton.snp.makeConstraints(loginButtonConstraints)
		passwordTextField.snp.makeConstraints(passwordTextFieldConstraints)
		emailTextField.snp.makeConstraints(emailTextFieldConstraints)
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
	
	func loginButtonConstraints(maker: ConstraintMaker) {
		maker.centerX.equalTo(view.snp.centerX)
		maker.centerY.equalTo(view.snp.centerY)
		maker.leading.equalTo(view.snp.leading).inset(20)
		maker.trailing.equalTo(view.snp.trailing).inset(20)
	}
	
	func passwordTextFieldConstraints(maker: ConstraintMaker) {
		maker.bottom.equalTo(loginButton.snp.top).offset(-50)
		maker.leading.equalTo(loginButton.snp.leading)
		maker.trailing.equalTo(loginButton.snp.trailing)
	}
	
	func emailTextFieldConstraints(maker: ConstraintMaker) {
		maker.bottom.equalTo(passwordTextField.snp.top).offset(-50)
		maker.leading.equalTo(loginButton.snp.leading)
		maker.trailing.equalTo(loginButton.snp.trailing)
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		loginButton.snp.updateConstraints(loginButtonConstraints)
		passwordTextField.snp.updateConstraints(passwordTextFieldConstraints)
		emailTextField.snp.updateConstraints(emailTextFieldConstraints)
	}
}
