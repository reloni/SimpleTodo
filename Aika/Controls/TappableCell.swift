//
//  DefaultCell.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 01.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

class TappableCell: UITableViewCell {
	var tapped: (() -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
