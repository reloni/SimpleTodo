//
//  SubtitleCell.swift
//  Aika
//
//  Created by Anton Efimenko on 31.03.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit

final class SubtitleCell: UITableViewCell {
    let label = Theme.Controls.label(withStyle: UIFont.TextStyle.footnote).configure {
        $0.textAlignment = .center
        $0.textColor = Theme.Colors.secondaryLabel
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        selectionStyle = .none
        contentView.addSubview(label)
        backgroundColor = Theme.Colors.background
        
        label.snp.makeConstraints {
            $0.edges.equalTo(contentView.snp.margins)
        }
    }
}
