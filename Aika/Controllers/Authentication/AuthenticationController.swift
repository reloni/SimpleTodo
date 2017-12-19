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
	
	let scrollView = UIScrollView().configure {
		$0.bounces = true
		$0.alwaysBounceVertical = true
		$0.isUserInteractionEnabled = true
		$0.keyboardDismissMode = .onDrag
	}
	
	lazy var topContainerView = UIView().configure {
		$0.clipsToBounds = true
		$0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		$0.addSubview(self.topOffsetView)
		$0.addSubview(self.authenticationTypeContainerView)
		$0.addSubview(self.passwordEnterContainerView)
		$0.addSubview(self.bottomOffsetView)
	}
	
	let topOffsetView = UIView().configure {
		$0.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .vertical)
	}
	
	lazy var authenticationTypeContainerView = UIView().configure { [unowned self] in
		$0.clipsToBounds = true
		$0.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		$0.addSubview(self.googleLoginButton)
		$0.addSubview(self.facebookLoginButton)
		$0.addSubview(self.passwordLoginButton)
	}
	
	lazy var passwordEnterContainerView = UIView().configure { [unowned self] in
		$0.clipsToBounds = true
		$0.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		$0.addSubview(self.actionButton)
		$0.addSubview(self.emailTextField)
		$0.addSubview(self.passwordTextField)
		$0.addSubview(self.supplementalButton)
	}
	
	let bottomOffsetView = UIView().configure {
		$0.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .vertical)
	}
	
	let googleLoginButton = Button().configure {
		_ = configureDefaultLoginButton($0)
		$0.title = "Log in with Google"
		$0.setImage(Theme.Images.google.resize(toWidth: 22), for: UIControlState.normal)
	}
	
	let facebookLoginButton = Button().configure {
		_ = configureDefaultLoginButton($0)
		$0.title = "Log in with Facebook"
		$0.setImage(Theme.Images.facebook.resize(toWidth: 22), for: UIControlState.normal)
	}
	
	let passwordLoginButton = Button().configure {
		_ = configureDefaultLoginButton($0)
		$0.title = "Log in with password"
		$0.setImage(Theme.Images.password.resize(toWidth: 22), for: UIControlState.normal)
	}
	
	let emailTextField = Theme.Controls.textField(withStyle: .body).configure {
		$0.placeholder = "Email"
		$0.detail = "Enter your email"
		$0.keyboardType = .emailAddress
		$0.autocapitalizationType = .none
		$0.returnKeyType = .next
		$0.isClearIconButtonEnabled = true
		$0.leftView = UIImageView(image: Theme.Images.email.resize(toWidth: 22))
		$0.leftViewOffset = 0
	}
	
	let passwordTextField = Theme.Controls.textField(withStyle: .body).configure {
		$0.placeholder = "Password"
		$0.detail = "Enter your password"
		$0.isSecureTextEntry = true
		$0.keyboardType = .default
		$0.returnKeyType = .done
		$0.isClearIconButtonEnabled = true
		$0.leftView = UIImageView(image: Theme.Images.password.resize(toWidth: 22))
		$0.leftViewOffset = 0
	}
	
	let actionButton = Button().configure {
		$0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
		$0.pulseColor = Theme.Colors.white
		$0.titleColor = Theme.Colors.white
	}
	
	let supplementalButton = Button().configure {
		$0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
		$0.pulseColor = Theme.Colors.white
		$0.titleColor = Theme.Colors.blueberry
	}
	
	let lostPasswordLabel = Theme.Controls.label(withStyle: UIFontTextStyle.caption2).configure {
		let attributedText = NSMutableAttributedString(string: "Lost password?")
		attributedText.addAttribute(NSAttributedStringKey.underlineStyle , value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, attributedText.string.count))
		$0.attributedText = attributedText
		$0.textColor = Theme.Colors.blueberry
		$0.textAlignment = .center
	}
	
	let gradientLayer = CAGradientLayer().configure {
		$0.colors = [Theme.Colors.pumkinLight.cgColor, Theme.Colors.pumkin.cgColor]
	}
	
	static func configureDefaultLoginButton(_ button: Button) -> Button {
		button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
		button.layer.cornerRadius = 3
		button.contentHorizontalAlignment = .center
		button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
		button.backgroundColor = Theme.Colors.clear
		button.pulseColor = Theme.Colors.white
		button.titleColor = Theme.Colors.white
		return button
	}
	
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
				               animations: { [weak self] in self?.emailTextField.setNeedsLayout(); self?.passwordTextField.setNeedsLayout(); self?.view.layoutIfNeeded(); })
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
			guard let email = alert?.textFields?.first?.text, email.count > 0 else { return }
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
