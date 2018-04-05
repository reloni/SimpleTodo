//
//  EditTaskController+Constraints.swift
//  Aika
//
//  Created by Anton Efimenko on 05.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import SnapKit
import UIKit

extension EditTaskController {
	func scrollViewConstraints(make: ConstraintMaker) {
		make.edges.equalTo(view).inset(UIEdgeInsets.zero)
	}
	
	func containerViewConstraints(make: ConstraintMaker) {
		make.edges.equalTo(scrollView).inset(UIEdgeInsets.zero)
		make.width.equalTo(scrollView)
	}
	
	func descriptionTextFieldConstraints(make: ConstraintMaker) {
		make.top.equalTo(containerView.snp.topMargin).offset(25)
		make.leading.equalTo(containerView.snp.leadingMargin)
		make.trailing.equalTo(containerView.snp.trailingMargin)
	}
	
	func targetDateViewConstraints(make: ConstraintMaker) {
		make.top.equalTo(descriptionTextField.snp.bottom).offset(25)
		make.leading.equalTo(containerView.snp.leadingMargin)
		make.trailing.equalTo(containerView.snp.trailingMargin)
	}
	
	func targetDatePickerViewConstraints(make: ConstraintMaker) {
		make.top.equalTo(targetDateView.snp.bottom).offset(-1)
		make.leading.equalTo(containerView.snp.leadingMargin)
		make.trailing.equalTo(containerView.snp.trailingMargin)
		datePickerHeightConstraint = make.height.equalTo(0).constraint
	}
	
	func taskRepeatDescriptionViewConstraints(make: ConstraintMaker) {
		make.top.equalTo(targetDatePickerView.snp.bottom).offset(-1)
		make.leading.equalTo(containerView.snp.leadingMargin)
		make.trailing.equalTo(containerView.snp.trailingMargin)
		taskRepeatDescriptionViewHeightConstraint = make.height.equalTo(0).constraint
	}
	
	func notesWrapperConstraints(make: ConstraintMaker) {
		make.top.equalTo(taskRepeatDescriptionView.snp.bottom).offset(25)
		make.leading.equalTo(containerView.snp.leadingMargin)
		make.trailing.equalTo(containerView.snp.trailingMargin)
		make.bottom.equalTo(containerView.snp.bottomMargin)
	}
	
	func notesStackConstraints(make: ConstraintMaker) {
		make.edges.equalTo(notesWrapper.snp.margins)
	}
}
