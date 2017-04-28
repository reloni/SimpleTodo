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
	
	let lostPasswordLabel: UILabel = {
		let label = Theme.Controls.label(withStyle: UIFontTextStyle.caption2)
		label.alpha = 0
		let attributedText = NSMutableAttributedString(string: "Lost password?")
		attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, attributedText.string.characters.count))
		label.attributedText = attributedText
		label.textColor = Theme.Colors.appleBlue
		label.textAlignment = .center
		return label
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
		if viewModel.mode == .logIn { containerView.addSubview(lostPasswordLabel) }
		
		actionButton.snp.makeConstraints(loginButtonConstraints)
		passwordTextField.snp.makeConstraints(passwordTextFieldConstraints)
		emailTextField.snp.makeConstraints(emailTextFieldConstraints)
		scrollView.snp.makeConstraints(scrollViewConstraints)
		supplementalButton.snp.makeConstraints(registrationButtonConstraints)
		containerView.snp.makeConstraints(containerViewConstraints)
		if viewModel.mode == .logIn { lostPasswordLabel.snp.makeConstraints(lostPasswordLabelConstraints) }
		
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
			UIView.animate(withDuration: 0.2, delay: 0.40, options: [], animations: { self.actionButton.alpha = 1 }, completion: nil)
			UIView.animate(withDuration: 0.2, delay: 0.55, options: [], animations: { self.supplementalButton.alpha = 1 }, completion: nil)
			UIView.animate(withDuration: 0.2, delay: 0.70, options: [], animations: { self.lostPasswordLabel.alpha = 1 }, completion: nil)
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
		
		if viewModel.mode == .logIn {
			lostPasswordLabel.rx.tapGesture().when(UIGestureRecognizerState.recognized).bindNext(showResetEmailDialog).disposed(by: bag)
		}
	}
	
	func showResetEmailDialog(recognizer: UIGestureRecognizer) {
		let alert = UIAlertController(title: "Reset password", message: "Enter your email and we will send instructions how to reset your password", preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.placeholder = "E-mail"
		}
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert, weak viewModel] _ in
			guard let email = alert?.textFields?.first?.text, email.characters.count > 0 else { return }
			viewModel?.resetPassword(email: email)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		present(alert, animated: true, completion: nil)
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
		maker.leading.equalTo(containerView.snp.leading).inset(20)
		maker.trailing.equalTo(containerView.snp.trailing).inset(20)
	}
	
	func registrationButtonConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(actionButton.snp.bottom).offset(25)
		maker.leading.equalTo(containerView.snp.leading).inset(20)
		maker.trailing.equalTo(containerView.snp.trailing).inset(20)
		if viewModel.mode == .registration { maker.bottom.equalTo(containerView).inset(50) }
	}
	
	func lostPasswordLabelConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(supplementalButton.snp.bottom).offset(25)
		maker.leading.equalTo(containerView.snp.leading).inset(20)
		maker.trailing.equalTo(containerView.snp.trailing).inset(20)
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
		
		if viewModel.mode == .logIn { lostPasswordLabel.snp.updateConstraints(lostPasswordLabelConstraints) }
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