//
//  TaskCell.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 05.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import RxGesture
import RxSwift

final class TaskCell : UITableViewCell {
	static let expandHeight: CGFloat = 35
	
	let bag = DisposeBag()
	
	let taskDescription: UILabel = {
		let text = Theme.Controls.label(withStyle: .body)
		text.lineBreakMode = .byWordWrapping
		text.numberOfLines = 0
		return text
	}()
	
	let targetDate: UILabel = {
		let text = Theme.Controls.label(withStyle: .footnote)
		text.textColor = Theme.Colors.secondaryLabel
		return text
	}()
	
	let repeatImage: UIImageView = {
		let image = UIImageView(image: Theme.Images.refresh)
		return image
	}()
	
	let completeActionView: TaskActonView = {
		return TaskActonView(text: "", image: Theme.Images.checked, expandHeight: TaskCell.expandHeight)
	}()
	
	let editActionView: TaskActonView = {
		return TaskActonView(text: "", image: Theme.Images.edit, expandHeight: TaskCell.expandHeight)
	}()
	
	let deleteActionView: TaskActonView = {
		return TaskActonView(text: "", image: Theme.Images.delete, expandHeight: TaskCell.expandHeight)
	}()
	
	lazy var actionsStack: UIStackView = {
		let stack = UIStackView()
		
		stack.axis = .horizontal
		stack.distribution = .fillEqually
		stack.spacing = 0
		stack.layoutEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
		
		stack.addArrangedSubview(self.completeActionView)
		stack.addArrangedSubview(self.editActionView)
		stack.addArrangedSubview(self.deleteActionView)

		return stack
	}()
	
	var heightConstraint: Constraint?
	
	var isExpanded: Bool = false {
		didSet
		{
			if !isExpanded {
				self.heightConstraint?.update(offset: 0)
			} else {
				self.heightConstraint?.update(offset: TaskCell.expandHeight)
			}
		}
	}
	
	var completeTapped: (() -> ())?
	var editTapped: (() -> ())?
	var deleteTapped: (() -> ())?
	
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		contentView.addSubview(taskDescription)
		contentView.addSubview(actionsStack)
		contentView.addSubview(targetDate)
		contentView.addSubview(repeatImage)
		
        taskDescription.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.vertical)
        taskDescription.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.vertical)
		
        targetDate.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 999), for: NSLayoutConstraint.Axis.vertical)
        targetDate.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.vertical)
		
		actionsStack.subviews.forEach { $0.backgroundColor = Theme.Colors.background }
        actionsStack.subviews.last?.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: NSLayoutConstraint.Axis.horizontal)
		
		completeActionView.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
			self?.completeTapped?()
		}).disposed(by: bag)
		editActionView.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
			self?.editTapped?()
		}).disposed(by: bag)
		deleteActionView.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
			self?.deleteTapped?()
		}).disposed(by: bag)
		
		taskDescription.snp.makeConstraints(makeTaskDescriptionConstraints)
		targetDate.snp.makeConstraints(makeTargetDateConstraints)
		actionsStack.snp.makeConstraints(makeActionsStackConstraints)
		repeatImage.snp.makeConstraints(makeRepeatImageConstraints(maker:))
		
		actionsStack.snp.makeConstraints {
			heightConstraint = $0.height.equalTo(0).priority(999).constraint
		}
	}
	
	func makeTaskDescriptionConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(contentView.snp.topMargin)
		maker.leading.equalTo(contentView.snp.leadingMargin)
		maker.trailing.equalTo(contentView.snp.trailingMargin)
	}
	
	func makeTargetDateConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(taskDescription.snp.bottom).offset(10)
		maker.leading.equalTo(contentView.snp.leadingMargin)
		maker.trailing.equalTo(repeatImage.snp.leading).offset(-10)
	}
	
	func makeRepeatImageConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(targetDate.snp.top)
		maker.bottom.equalTo(targetDate.snp.bottom)
		maker.width.equalTo(repeatImage.snp.height)
	}
	
	func makeActionsStackConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(targetDate.snp.bottom).offset((targetDate.text?.count ?? 0) == 0 ? 0 : 10)
		maker.leading.equalTo(contentView.snp.leading)
		maker.trailing.equalTo(contentView.snp.trailing)
		maker.bottom.equalTo(contentView.snp.bottom)
	}

	override func updateConstraints() {
		super.updateConstraints()

		actionsStack.snp.updateConstraints(makeActionsStackConstraints)
	}
}
