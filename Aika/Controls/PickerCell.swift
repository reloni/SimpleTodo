//
//  PickerCell.swift
//  Aika
//
//  Created by Anton Efimenko on 13.03.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit

final class PickerCell: UITableViewCell {
    let picker = UIPickerView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        contentView.addSubview(picker)
        
        picker.snp.makeConstraints {
            $0.edges.equalTo(contentView.snp.edges)
        }

        contentView.clipsToBounds = true
    }
}
