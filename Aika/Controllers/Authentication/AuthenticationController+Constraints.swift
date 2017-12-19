//
//  AuthenticationController+Constraints.swift
//  Aika
//
//  Created by Anton Efimenko on 19.12.2017.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import SnapKit
import UIKit

extension AuthenticationController {
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
		maker.top.equalTo(passwordEnterContainerView.snp.topMargin)
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
		maker.bottom.equalTo(passwordEnterContainerView.snp.bottomMargin)
	}
}
