//
//  SubtitleCell.swift
//  Aika
//
//  Created by Anton Efimenko on 31.03.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit

final class SubtitleCell: UITableViewCell {
    let label = Theme.Controls.label(withStyle: UIFontTextStyle.footnote).configure {
        $0.textAlignment = .center
        $0.textColor = Theme.Colors.romanSilver
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
        backgroundColor = Theme.Colors.isabelline
        
        label.snp.makeConstraints {
            $0.edges.equalTo(contentView.snp.margins)
        }
    }
}
