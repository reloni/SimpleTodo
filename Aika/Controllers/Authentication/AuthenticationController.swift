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
		field.leftView = UIImageView(image: Theme.Images.email.resize(toWidth: 22))
		field.leftViewOffset = 0
		
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
		field.leftView = UIImageView(image: Theme.Images.password.resize(toWidth: 22))
		field.leftViewOffset = 0
		
		return field
	}()
	
	let actionButton: Button = {
		let button = Button()
		button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
		button.alpha = 0
		button.pulseColor = Theme.Colors.white
		button.titleColor = Theme.Colors.white
		return button
	}()
	
	let supplementalButton: Button = {
		let button = Button()
		button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
		button.alpha = 0
		button.pulseColor = Theme.Colors.white
		button.titleColor = Theme.Colors.blueberry
		return button
	}()
	
	let lostPasswordLabel: UILabel = {
		let label = Theme.Controls.label(withStyle: UIFontTextStyle.caption2)
		label.alpha = 0
		let attributedText = NSMutableAttributedString(string: "Lost password?")
		attributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, attributedText.string.characters.count))
		label.attributedText = attributedText
		label.textColor = Theme.Colors.blueberry
		label.textAlignment = .center
		return label
	}()
	
	let gradientLayer: CAGradientLayer = {
		let gradient = CAGradientLayer()
		
		gradient.colors = [Theme.Colors.pumkinLight.cgColor, Theme.Colors.pumkin.cgColor]
		return gradient
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
		
		view.layer.insertSublayer(gradientLayer, at: 0)
		
		actionButton.title = viewModel.actionButtonTitle
		supplementalButton.title = viewModel.supplementalButtonTitle
		
		view.backgroundColor = UIColor.white
		
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		emailTextField.text = viewModel.email
		passwordTextField.text = viewModel.password
	}
	
	override func viewWillLayoutSubviews() {
		gradientLayer.frame = view.bounds
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
		
		actionButton.rx.tap.subscribe(onNext: { [weak self] _ in
			self?.textFieldsResignFirstResponder()
			self?.performAction()
		}).disposed(by: bag)
		
		supplementalButton.rx.tap.subscribe(onNext: { [weak self] _ in
			self?.textFieldsResignFirstResponder()
			self?.viewModel.performSupplementalAction()
		}).disposed(by: bag)
		
		viewModel.errors.subscribe().disposed(by: bag)
		
		if viewModel.mode == .logIn {
			lostPasswordLabel.rx.tapGesture().when(UIGestureRecognizerState.recognized)
				.subscribe(onNext: { [weak self] recognizer in self?.showResetEmailDialog(recognizer: recognizer) }).disposed(by: bag)
		}
	}
	
	func textFieldsResignFirstResponder() {
		if passwordTextField.isFirstResponder { passwordTextField.resignFirstResponder(); return }
		if emailTextField.isFirstResponder { emailTextField.resignFirstResponder(); return }
	}
	
	func showResetEmailDialog(recognizer: UIGestureRecognizer) {
		let alert = UIAlertController(title: "Reset password", message: "Enter your email and we will send instructions how to reset your password", preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.placeholder = "E-mail"
			textField.keyboardType = .emailAddress
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
