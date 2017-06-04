//
//  TasksTableBackground.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 03.06.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

final class TasksTableBackground: UIView {
	let titleLabel: UILabel = {
		let lbl = Theme.Controls.label(withStyle: UIFontTextStyle.title1)
		lbl.text = "No tasks"
		return lbl
	}()
	
	let subtitleLabel: UILabel = {
		let lbl = Theme.Controls.label(withStyle: UIFontTextStyle.title2)
		lbl.text = "Press \"+\" button to add new task"
		return lbl
	}()
	
	init() {
		super.init(frame: CGRect.zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup() {
		addSubview(titleLabel)
		addSubview(subtitleLabel)
		
		titleLabel.snp.makeConstraints {
			$0.center.equalTo(self.snp.center)
		}
		
		subtitleLabel.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(20)
			$0.centerX.equalTo(snp.centerX)
		}
	}
}