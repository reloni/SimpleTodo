//
//  TableSectionHeader.swift
//  Aika
//
//  Created by Anton Efimenko on 14.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

final class TableSectionHeader: UITableViewHeaderFooterView {
    let label = Theme.Controls.label(withStyle: UIFont.TextStyle.caption1)
	
	init() {
		super.init(reuseIdentifier: nil)
		setup()
	}
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		contentView.addSubview(label)
		
		clipsToBounds = true
		contentView.backgroundColor = Theme.Colors.background
		contentView.alpha = 1
		
		label.snp.makeConstraints { $0.edges.equalTo(contentView.snp.margins) }
	}
}
