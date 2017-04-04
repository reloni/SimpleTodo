//
//  SignInController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 20.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import Material
import RxCocoa

final class SignInController : UIViewController {
	let viewModel: SignInViewModel
	let bag = DisposeBag()
	
	let scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.bounces = true
		scroll.isUserInteractionEnabled = true
		scroll.keyboardDismissMode = .onDrag
		return scroll
	}()
	
	let containerView: UIView = {
		let view = UIView()
		return view
	}()
	
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
	
	init(viewModel: SignInViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		emailTextField.text = viewModel.email
		passwordTextField.text = viewModel.password
		
		emailTextField.delegate = self
		passwordTextField.delegate = self
		
		view.addSubview(scrollView)
		scrollView.addSubview(containerView)
		containerView.addSubview(loginButton)
		containerView.addSubview(emailTextField)
		containerView.addSubview(passwordTextField)
		
		loginButton.snp.makeConstraints(loginButtonConstraints)
		passwordTextField.snp.makeConstraints(passwordTextFieldConstraints)
		emailTextField.snp.makeConstraints(emailTextFieldConstraints)
		scrollView.snp.makeConstraints(scrollViewConstraints)
		containerView.snp.makeConstraints(containerViewConstraints)
		
		NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
			.subscribe(onNext: { [weak self] notification in
				self?.scrollView.updatecontentInsetFor(keyboardHeight: notification.keyboardHeight() + 25)
			}).disposed(by: bag)
		
		NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
			.subscribe(onNext: { [weak self] notification in
				self?.scrollView.updatecontentInsetFor(keyboardHeight: 0)
			}).disposed(by: bag)
		
		bind()
	}
	
	func bind() {
		loginButton.rx.tap.subscribe(onNext: { [weak self] in self?.login() }).disposed(by: bag)
		viewModel.errors.subscribe().disposed(by: bag)
	}
	
	func login() {
		viewModel.logIn(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
	}
	
//	func keyboardWillShow(_ notification: Notification) {
//		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: notification.keyboardHeight() + 25, right: 0)
//
////		let point = CGPoint(x: passwordTextField.frame.origin.x, y: passwordTextField.frame.origin.y - passwordTextField.frame.height)
////		if !view.frame.contains(point) {
////			scrollView.setContentOffset(CGPoint(x: 0, y: point.y - scrollView.contentInset.bottom), animated: true)
////		}
//	}

	func scrollViewConstraints(maker: ConstraintMaker) {
		maker.edges.equalTo(view)
	}
	
	func containerViewConstraints(maker: ConstraintMaker) {
		maker.centerX.equalTo(scrollView.snp.centerX)
		maker.centerY.equalTo(scrollView.snp.centerY)
		maker.width.equalTo(scrollView)
		maker.bottom.equalTo(scrollView).inset(10)
	}
	
	func emailTextFieldConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(containerView.snp.top).offset(50)
		maker.leading.equalTo(loginButton.snp.leading)
		maker.trailing.equalTo(loginButton.snp.trailing)
	}
	
	func passwordTextFieldConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(emailTextField.snp.bottom).offset(50)
		maker.leading.equalTo(loginButton.snp.leading)
		maker.trailing.equalTo(loginButton.snp.trailing)
	}

	func loginButtonConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(passwordTextField.snp.bottom).offset(50)
		maker.leading.equalTo(view.snp.leading).inset(20)
		maker.trailing.equalTo(view.snp.trailing).inset(20)
		maker.bottom.equalTo(containerView).inset(50)
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		loginButton.snp.updateConstraints(loginButtonConstraints)
		passwordTextField.snp.updateConstraints(passwordTextFieldConstraints)
		emailTextField.snp.updateConstraints(emailTextFieldConstraints)
		scrollView.snp.updateConstraints(scrollViewConstraints)
		containerView.snp.updateConstraints(containerViewConstraints)
	}
}

extension SignInController : UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == emailTextField {
			_ = passwordTextField.becomeFirstResponder()
		} else {
			textField.resignFirstResponder()
			login()
		}
		return true
	}
}
