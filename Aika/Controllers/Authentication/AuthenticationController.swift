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
	
	var authenticationTypeContainerHeightConstraint: Constraint!
	var passwordContainerHeightConstraint: Constraint!
	
	let scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.bounces = true
		scroll.alwaysBounceVertical = true
		scroll.isUserInteractionEnabled = true
		scroll.keyboardDismissMode = .onDrag
		return scroll
	}()
	
	lazy var topContainerView: UIView = {
		let view = UIView()
		view.clipsToBounds = true
		view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		view.addSubview(self.topOffsetView)
		view.addSubview(self.authenticationTypeContainerView)
		view.addSubview(self.passwordEnterContainerView)
		view.addSubview(self.bottomOffsetView)
		return view
	}()
	
	let topOffsetView: UIView = {
		let view = UIView()
		view.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .vertical)
		return view
	}()
	
	lazy var authenticationTypeContainerView: UIView = {
		let view = UIView()
		view.clipsToBounds = true
		view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		view.addSubview(self.googleLoginButton)
		view.addSubview(self.facebookLoginButton)
		view.addSubview(self.passwordLoginButton)
		return view
	}()
	
	lazy var passwordEnterContainerView: UIView = {
		let view = UIView()
		view.clipsToBounds = true
		view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		view.addSubview(self.actionButton)
		view.addSubview(self.emailTextField)
		view.addSubview(self.passwordTextField)
		view.addSubview(self.supplementalButton)
		return view
	}()
	
	let bottomOffsetView: UIView = {
		let view = UIView()
		view.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .vertical)
		return view
	}()
	
	let googleLoginButton: Button = {
		let button = Button()
		button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
		button.layer.cornerRadius = 3
		button.contentHorizontalAlignment = .center
		button.title = "Log in with Google"
		button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
		button.setImage(Theme.Images.google.resize(toWidth: 22), for: UIControlState.normal)
		button.backgroundColor = Theme.Colors.clear
		button.pulseColor = Theme.Colors.white
		button.titleColor = Theme.Colors.white
		return button
	}()
	
	let facebookLoginButton: Button = {
		let button = Button()
		button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
		button.layer.cornerRadius = 3
		button.contentHorizontalAlignment = .center
		button.title = "Log in with Facebook"
		button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
		button.setImage(Theme.Images.facebook.resize(toWidth: 22), for: UIControlState.normal)
		button.backgroundColor = Theme.Colors.clear
		button.pulseColor = Theme.Colors.white
		button.titleColor = Theme.Colors.white
		return button
	}()
	
	let passwordLoginButton: Button = {
		let button = Button()
		button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
		button.layer.cornerRadius = 3
		button.contentHorizontalAlignment = .center
		button.title = "Log in with password"
		button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
		button.setImage(Theme.Images.password.resize(toWidth: 22), for: UIControlState.normal)
		button.backgroundColor = Theme.Colors.clear
		button.pulseColor = Theme.Colors.white
		button.titleColor = Theme.Colors.white
		return button
	}()
	
	let emailTextField: TextField = {
		let field = Theme.Controls.textField(withStyle: .body)
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
		button.pulseColor = Theme.Colors.white
		button.titleColor = Theme.Colors.white
		return button
	}()
	
	let supplementalButton: Button = {
		let button = Button()
		button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
		button.pulseColor = Theme.Colors.white
		button.titleColor = Theme.Colors.blueberry
		return button
	}()
	
	let lostPasswordLabel: UILabel = {
		let label = Theme.Controls.label(withStyle: UIFontTextStyle.caption2)
		let attributedText = NSMutableAttributedString(string: "Lost password?")
		attributedText.addAttribute(NSAttributedStringKey.underlineStyle , value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, attributedText.string.characters.count))
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
		scrollView.addSubview(topContainerView)
		if viewModel.mode == .logIn { passwordEnterContainerView.addSubview(lostPasswordLabel) }
		
		topContainerView.snp.makeConstraints(topContainerViewConstraints)
		topOffsetView.snp.makeConstraints(topOffsetViewConstraints)
		bottomOffsetView.snp.makeConstraints(bottomOffsetViewConstraints)
		actionButton.snp.makeConstraints(loginButtonConstraints)
		passwordTextField.snp.makeConstraints(passwordTextFieldConstraints)
		googleLoginButton.snp.makeConstraints(googleLoginButtonConstraints)
		facebookLoginButton.snp.makeConstraints(facebookLoginButtonConstraints)
		passwordLoginButton.snp.makeConstraints(passwordLoginButtonConstraints)
		emailTextField.snp.makeConstraints(emailTextFieldConstraints)
		scrollView.snp.makeConstraints(scrollViewConstraints)
		supplementalButton.snp.makeConstraints(registrationButtonConstraints)
		passwordEnterContainerView.snp.makeConstraints(passwordEnterContainerViewConstraints)
		authenticationTypeContainerView.snp.makeConstraints(authenticationContainerViewConstraints)
		
		if viewModel.mode == .logIn {
			lostPasswordLabel.snp.makeConstraints(lostPasswordLabelConstraints)
		}
		
		if viewModel.mode == .registration {
			passwordContainerHeightConstraint.deactivate()
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
		
		googleLoginButton.rx.tap.subscribe(onNext: { [weak self] _ in
			self?.textFieldsResignFirstResponder()
			self?.viewModel.authenticateWithGoogle()
		}).disposed(by: bag)
		
		facebookLoginButton.rx.tap.subscribe(onNext: { [weak self] _ in
			self?.textFieldsResignFirstResponder()
			self?.viewModel.authenticateWithFacebook()
		}).disposed(by: bag)
		
		passwordLoginButton.rx.tap.subscribe(onNext: { [weak self] _ in
			self?.textFieldsResignFirstResponder()
			self?.viewModel.toggleShowPasswordOrRegistrationEnter()
		}).disposed(by: bag)
		
		viewModel.showAuthenticationTypes.subscribe(
			onNext: { [weak self] v in
				if v { self?.authenticationTypeContainerHeightConstraint.deactivate() }
				else { self?.authenticationTypeContainerHeightConstraint.activate() }
			}).disposed(by: bag)
		
		viewModel.showPasswordOrRegistrationEnter.skip(1).subscribe(
			onNext: { [weak self] v in
				if v { self?.passwordContainerHeightConstraint.deactivate() }
				else { self?.passwordContainerHeightConstraint.activate() }
				UIView.animate(withDuration: 0.3,
				               animations: { [weak self] in self?.view.layoutIfNeeded(); self?.emailTextField.reload(); self?.passwordTextField.reload() })
		}).disposed(by: bag)
		
		viewModel.errors.subscribe().disposed(by: bag)
		
		if viewModel.mode == .logIn {
			lostPasswordLabel.rx.tapGesture().when(UIGestureRecognizerState.recognized)
				.subscribe(onNext: { [weak self] recognizer in self?.showResetEmailDialog(recognizer: recognizer) }).disposed(by: bag)
			
			let recognizer = UITapGestureRecognizer(target: self, action: #selector(changeServer))
			recognizer.numberOfTapsRequired = 5
			scrollView.isUserInteractionEnabled = true
			scrollView.addGestureRecognizer(recognizer)
		}
	}
	
	
	@objc func changeServer() {
		let alert = createAlertContoller(withTitle: "Server host", message: "")
		
		alert.addTextField { textField in
			textField.placeholder = AppConstants.host
			textField.text = UserDefaults.standard.serverHost
			textField.keyboardType = .URL
		}
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert, weak viewModel] _ in
			let newHost = alert?.textFields?.first?.text ?? AppConstants.host
			viewModel?.update(host: newHost)
			UserDefaults.standard.serverHost = newHost
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		present(alert, animated: true, completion: nil)
	}
	
	func textFieldsResignFirstResponder() {
		if passwordTextField.isFirstResponder { passwordTextField.resignFirstResponder(); return }
		if emailTextField.isFirstResponder { emailTextField.resignFirstResponder(); return }
	}
	
	func showResetEmailDialog(recognizer: UIGestureRecognizer) {
		let alert = createAlertContoller(withTitle: "Reset password",
		                                 message: "Enter your email and we will send instructions how to reset your password")

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
		maker.edges.equalTo(view).inset(UIEdgeInsets.zero)
	}
	
	func topContainerViewConstraints(maker: ConstraintMaker) {
		maker.edges.equalTo(scrollView).inset(UIEdgeInsets.zero)
		maker.width.equalTo(scrollView)
		maker.height.greaterThanOrEqualTo(scrollView.snp.height)
		
	}
	
	func topOffsetViewConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(topContainerView.snp.topMargin)
		maker.leading.equalTo(topContainerView.snp.leadingMargin)
		maker.trailing.equalTo(topContainerView.snp.trailingMargin)
		maker.height.equalTo(bottomOffsetView.snp.height)
	}
	
	func bottomOffsetViewConstraints(maker: ConstraintMaker) {
		maker.leading.equalTo(topContainerView.snp.leadingMargin)
		maker.trailing.equalTo(topContainerView.snp.trailingMargin)
		maker.bottom.equalTo(topContainerView.snp.bottomMargin)
	}
	
	func authenticationContainerViewConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(topOffsetView.snp.bottom)
		maker.leading.equalTo(topContainerView.snp.leadingMargin)
		maker.trailing.equalTo(topContainerView.snp.trailingMargin)
		authenticationTypeContainerHeightConstraint = maker.height.equalTo(0).constraint
	}
	
	func passwordEnterContainerViewConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(authenticationTypeContainerView.snp.bottom)
		maker.leading.equalTo(topContainerView.snp.leadingMargin)
		maker.trailing.equalTo(topContainerView.snp.trailingMargin)
		maker.bottom.equalTo(bottomOffsetView.snp.top).priority(999)
		passwordContainerHeightConstraint = maker.height.equalTo(0).constraint
	}
	
	func googleLoginButtonConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(authenticationTypeContainerView.snp.topMargin).priority(999)
		maker.leading.equalTo(authenticationTypeContainerView.snp.leadingMargin)
		maker.trailing.equalTo(authenticationTypeContainerView.snp.trailingMargin)
	}
	
	func facebookLoginButtonConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(googleLoginButton.snp.bottom).offset(10)
		maker.leading.equalTo(authenticationTypeContainerView.snp.leadingMargin)
		maker.trailing.equalTo(authenticationTypeContainerView.snp.trailingMargin)
	}
	
	func passwordLoginButtonConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(facebookLoginButton.snp.bottom).offset(10)
		maker.leading.equalTo(authenticationTypeContainerView.snp.leadingMargin)
		maker.trailing.equalTo(authenticationTypeContainerView.snp.trailingMargin)
		maker.bottom.equalTo(authenticationTypeContainerView.snp.bottomMargin)
	}
	
	func emailTextFieldConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(passwordEnterContainerView.snp.topMargin)//.priority(999)
		maker.leading.equalTo(passwordEnterContainerView.snp.leadingMargin)
		maker.trailing.equalTo(passwordEnterContainerView.snp.trailingMargin)
	}
	
	func passwordTextFieldConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(emailTextField.snp.bottom).offset(50).priority(999)
		maker.leading.equalTo(passwordEnterContainerView.snp.leadingMargin)
		maker.trailing.equalTo(passwordEnterContainerView.snp.trailingMargin)
	}

	func loginButtonConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(passwordTextField.snp.bottom).offset(50).priority(999)
		maker.leading.equalTo(passwordEnterContainerView.snp.leadingMargin)
		maker.trailing.equalTo(passwordEnterContainerView.snp.trailingMargin)
	}
	
	func registrationButtonConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(actionButton.snp.bottom).offset(10).priority(999)
		maker.leading.equalTo(passwordEnterContainerView.snp.leadingMargin)
		maker.trailing.equalTo(passwordEnterContainerView.snp.trailingMargin)
		if viewModel.mode == .registration {
			maker.bottom.equalTo(passwordEnterContainerView.snp.bottomMargin).priority(999)
		}
	}
	
	func lostPasswordLabelConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(supplementalButton.snp.bottom).offset(10).priority(999)
		maker.leading.equalTo(passwordEnterContainerView.snp.leadingMargin)
		maker.trailing.equalTo(passwordEnterContainerView.snp.trailingMargin)
		maker.bottom.equalTo(passwordEnterContainerView.snp.bottomMargin)//.priority(999)
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
