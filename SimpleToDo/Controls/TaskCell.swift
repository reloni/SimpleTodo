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
		let text = UILabel()
		text.lineBreakMode = .byWordWrapping
		text.numberOfLines = 0
		text.font = Theme.Fonts.main
		return text
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
	
	var isExpanded: Bool = false
		{
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
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		contentView.addSubview(taskDescription)
		contentView.addSubview(actionsStack)
		
		taskDescription.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.vertical)
		taskDescription.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.vertical)
		
		actionsStack.subviews.forEach { $0.backgroundColor = Theme.Colors.backgroundLightGray }
		actionsStack.subviews.last?.setContentHuggingPriority(1, for: UILayoutConstraintAxis.horizontal)
		
		completeActionView.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
			self?.completeTapped?()
		}).addDisposableTo(bag)
		editActionView.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
			self?.editTapped?()
		}).addDisposableTo(bag)
		deleteActionView.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
			self?.deleteTapped?()
		}).addDisposableTo(bag)
		
		taskDescription.snp.makeConstraints(makeTaskDescriptionConstraints)
		actionsStack.snp.makeConstraints(makeActionsStackConstraints)
		
		actionsStack.snp.makeConstraints {
			heightConstraint = $0.height.equalTo(0).priority(999).constraint
		}
	}
	
	func makeTaskDescriptionConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(contentView.snp.top).offset(15)
		maker.leading.equalTo(contentView.snp.leading).offset(10)
		maker.trailing.equalTo(contentView.snp.trailing).offset(-10)
	}
	
	func makeActionsStackConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(taskDescription.snp.bottom).offset(10)
		maker.leading.equalTo(contentView.snp.leading)
		maker.trailing.equalTo(contentView.snp.trailing)
		maker.bottom.equalTo(contentView.snp.bottom)
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		
		taskDescription.snp.updateConstraints(makeTaskDescriptionConstraints)
		actionsStack.snp.updateConstraints(makeActionsStackConstraints)
	}
}
