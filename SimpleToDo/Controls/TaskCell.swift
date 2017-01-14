//
//  TaskCell.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 05.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import SnapKit
import Material
import UIKit
import RxGesture
import RxSwift

final class TaskCell : UITableViewCell {
	var bag = DisposeBag()
	
	let taskDescription: UILabel = {
		let text = UILabel()
		text.font = Theme.Fonts.Main
		return text
	}()
	
	let completeActionView: TaskActonView = {
		return TaskActonView(text: "Complete", image: Theme.Images.checked)
	}()
	
	let editActionView: TaskActonView = {
		return TaskActonView(text: "Edit", image: Theme.Images.edit)
	}()
	
	let deleteActionView: TaskActonView = {
		return TaskActonView(text: "Delete", image: Theme.Images.delete)
	}()
	
	lazy var actionsStack: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.distribution = .fill
		stack.spacing = 0
		
		let spacingView: () -> UIView = {
			let v = UIView()
			v.width = 10
			return v
		}
		
		stack.addArrangedSubview(self.completeActionView)
		stack.addArrangedSubview(spacingView())
		stack.addArrangedSubview(self.editActionView)
		stack.addArrangedSubview(spacingView())
		stack.addArrangedSubview(self.deleteActionView)
		stack.addArrangedSubview(UIView())

		return stack
	}()
	
	var heightConstraint: Constraint?
	
	var isExpanded: Bool = false
		{
		didSet
		{
			if !isExpanded {
				heightConstraint?.update(offset: 0)
			} else {
				heightConstraint?.update(offset: 35)
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
		
		actionsStack.subviews.forEach { $0.backgroundColor = Theme.Colors.backgroundLightGray }
		actionsStack.subviews.last?.setContentHuggingPriority(1, for: UILayoutConstraintAxis.horizontal)

		completeActionView.rx.gesture(.tap).subscribe(onNext: { [weak self] _ in
			self?.completeTapped?()
		}).addDisposableTo(bag)
		editActionView.rx.gesture(.tap).subscribe(onNext: { [weak self] _ in
			self?.editTapped?()
		}).addDisposableTo(bag)
		deleteActionView.rx.gesture(.tap).subscribe(onNext: { [weak self] _ in
			self?.deleteTapped?()
		}).addDisposableTo(bag)
		updateConstraints()
	}
	
	override func prepareForReuse() {
		bag = DisposeBag()
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		
		taskDescription.snp.remakeConstraints { make in
			make.top.equalTo(contentView.snp.top).offset(15)
			make.leading.equalTo(contentView.snp.leading).offset(10)
			make.trailing.equalTo(contentView.snp.trailing).offset(-10)
		}
		
		actionsStack.snp.remakeConstraints { make in
			make.top.equalTo(taskDescription.snp.bottom).offset(10)
			make.leading.equalTo(contentView.snp.leading)
			make.trailing.equalTo(contentView.snp.trailing)
			make.bottom.equalTo(contentView.snp.bottom)
			heightConstraint = make.height.equalTo(0).priority(999).constraint
		}
	}
}
