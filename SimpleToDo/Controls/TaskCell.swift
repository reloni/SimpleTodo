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

final class TaskCell : UITableViewCell {
	let taskDescription: UILabel = {
		let text = UILabel()
		return text
	}()
	
	let actionsStack: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.distribution = .fillProportionally
		stack.spacing = 10
		return stack
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		contentView.addSubview(taskDescription)
		updateConstraints()
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		
		taskDescription.snp.remakeConstraints { make in
			make.top.equalTo(contentView.snp.top).offset(10)
			make.leading.equalTo(contentView.snp.leading).offset(10)
			make.trailing.equalTo(contentView.snp.trailing).offset(10)
		}
		
		
	}
}
