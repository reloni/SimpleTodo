//
//  AuthenticationController.swift
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

final class AuthenticationController : UIViewController {
	let viewModel: AuthenticationViewModel
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
		let field = Theme.Controls.textField(withStyle: .body)
		field.alpha = 0
		field.placeholder = "Email"
		field.detail = "Enter your email"
		field.keyboardType = .emailAddress
		field.autocapitalizationType = .none
		field.returnKeyType = .next
		field.isClearIconButtonEnabled = true
		return field
	}()
	
	let passwordTextField: TextField = {
		let field = Theme.Controls.textField(withStyle: .body)
		field.alpha = 0
		field.placeholder = "Password"
		field.detail = "Enter your password"
		field.isSecureTextEntry = true
		field.keyboardType = .default
		field.returnKeyType = .done
		field.isClearIconButtonEnabled = true
		return field
	}()
	
	let actionButton: Button = {
		let button = Button()
		button.alpha = 0
		button.pulseColor = Theme.Colors.white
		button.backgroundColor = Theme.Colors.appleBlue
		button.titleColor = Theme.Colors.white
		return button
	}()
	
	let supplementalButton: Button = {
		let button = Button()
		button.alpha = 0
		button.pulseColor = Theme.Colors.lightGray
		button.backgroundColor = Theme.Colors.white
		button.titleColor = Theme.Colors.appleBlue
		return button
	}()
	
	init(viewModel: AuthenticationViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		actionButton.title = viewModel.actionButtonTitle
		supplementalButton.title = viewModel.supplementalButtonTitle
		
		view.backgroundColor = UIColor.white
		
		emailTextField.text = viewModel.email
		passwordTextField.text = viewModel.password
		
		emailTextField.delegate = self
		passwordTextField.delegate = self
		
		view.addSubview(scrollView)
		scrollView.addSubview(containerView)
		containerView.addSubview(actionButton)
		containerView.addSubview(emailTextField)
		containerView.addSubview(passwordTextField)
		containerView.addSubview(supplementalButton)
		
		actionButton.snp.makeConstraints(loginButtonConstraints)
		passwordTextField.snp.makeConstraints(passwordTextFieldConstraints)
		emailTextField.snp.makeConstraints(emailTextFieldConstraints)
		scrollView.snp.makeConstraints(scrollViewConstraints)
		supplementalButton.snp.makeConstraints(registrationButtonConstraints)
		containerView.snp.makeConstraints(containerViewConstraints)
		
		if viewModel.mode == .registration {
			emailTextField.alpha = 1
			passwordTextField.alpha = 1
			actionButton.alpha = 1
			supplementalButton.alpha = 1
		}
		
		bind()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if viewModel.mode == .logIn {
			UIView.animate(withDuration: 0.2, delay: 0.1, options: [], animations: { self.emailTextField.alpha = 1 }, completion: nil)
			UIView.animate(withDuration: 0.2, delay: 0.25, options: [], animations: { self.passwordTextField.alpha = 1 }, completion: nil)
			UIView.animate(withDuration: 0.2, delay: 0.4, options: [], animations: { self.actionButton.alpha = 1 }, completion: nil)
			UIView.animate(withDuration: 0.2, delay: 0.55, options: [], animations: { self.supplementalButton.alpha = 1 }, completion: nil)
		}
	}
	
	func bind() {
		NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
			.subscribe(onNext: { [weak self] notification in
				self?.scrollView.updatecontentInsetFor(keyboardHeight: notification.keyboardHeight() + 25)
			}).disposed(by: bag)
		
		NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
			.subscribe(onNext: { [weak self] notification in
				self?.scrollView.updatecontentInsetFor(keyboardHeight: 0)
			}).disposed(by: bag)
		
		actionButton.rx.tap.bindNext(performAction).disposed(by: bag)
		
		supplementalButton.rx.tap.bindNext(viewModel.performSupplementalAction).disposed(by: bag)
		
		viewModel.errors.subscribe().disposed(by: bag)
	}
	
	func performAction() {
		viewModel.performAction(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
	}

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
		maker.leading.equalTo(actionButton.snp.leading)
		maker.trailing.equalTo(actionButton.snp.trailing)
	}
	
	func passwordTextFieldConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(emailTextField.snp.bottom).offset(50)
		maker.leading.equalTo(actionButton.snp.leading)
		maker.trailing.equalTo(actionButton.snp.trailing)
	}

	func loginButtonConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(passwordTextField.snp.bottom).offset(50)
		maker.leading.equalTo(view.snp.leading).inset(20)
		maker.trailing.equalTo(view.snp.trailing).inset(20)
	}
	
	func registrationButtonConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(actionButton.snp.bottom).offset(25)
		maker.leading.equalTo(view.snp.leading).inset(20)
		maker.trailing.equalTo(view.snp.trailing).inset(20)
		maker.bottom.equalTo(containerView).inset(50)
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		actionButton.snp.updateConstraints(loginButtonConstraints)
		passwordTextField.snp.updateConstraints(passwordTextFieldConstraints)
		emailTextField.snp.updateConstraints(emailTextFieldConstraints)
		scrollView.snp.updateConstraints(scrollViewConstraints)
		containerView.snp.updateConstraints(containerViewConstraints)
		supplementalButton.snp.updateConstraints(registrationButtonConstraints)
	}
}

extension AuthenticationController : UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == emailTextField {
			_ = passwordTextField.becomeFirstResponder()
		} else {
			textField.resignFirstResponder()
			performAction()
		}
		return true
	}
}
