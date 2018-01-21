//
//  SwitchView.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 08.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import SnapKit

final class SwitchView : UIView {
	let wrapper: UIStackView = {
		let stack = UIStackView()
		
		stack.axis = .horizontal
		stack.distribution = .fillProportionally
		stack.spacing = 10
		
		return stack
	}()
	
	let titleLabel: UILabel = {
		let label = Theme.Controls.label(withStyle: .body)
		return label
	}()
	
	let switchControl: UISwitch = {
		return UISwitch()
	}()
	
	init() {
		super.init(frame: CGRect.zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		layoutMargins = .zero

		addSubview(wrapper)
		wrapper.addArrangedSubview(titleLabel)
		wrapper.addArrangedSubview(switchControl)
		
		titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: UILayoutConstraintAxis.horizontal)
		switchControl.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: UILayoutConstraintAxis.horizontal)
		
		wrapper.snp.makeConstraints(makeWrapperConstraints)
	}
	
	func makeWrapperConstraints(maker: ConstraintMaker) {
		maker.edges.equalTo(self.snp.margins)
	}
}
