//
//  SwitchCell.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 01.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

final class SwitchCell: DefaultCell {
	var switchChanged: ((Bool) -> Void)?
	
	let switchView = UISwitch()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	deinit {
		(accessoryView as? UISwitch)?.removeTarget(self, action: #selector(switched), for: .valueChanged)
	}
	
	func setup() {
		switchView.addTarget(self, action: #selector(switched), for: .valueChanged)
		accessoryView = switchView
	}
	
	@objc func switched(switchView: UISwitch) {
		switchChanged?(switchView.isOn)
	}
}
