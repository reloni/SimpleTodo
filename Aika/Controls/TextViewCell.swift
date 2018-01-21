//
//  TextViewCell.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 08.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import SnapKit
import UIKit
import Material

final class TextViewCell : UITableViewCell {
	let textView: TextView = {
		return TextView.generic
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		contentView.addSubview(textView)
	}
	
	func makeTextViewConstraints(maker: ConstraintMaker) {
		maker.edges.equalTo(contentView)
	}
}
