//
//  CalendarDateCell.swift
//  Aika
//
//  Created by Anton Efimenko on 17.04.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit

final class CalendarDateCell: UITableViewCell {
    class DateView: UIView {
        let label = Theme.Controls.label(withStyle: .headline).configure { label in
            label.textAlignment = .center
        }
        
        init() {
            super.init(frame: .zero)
            addSubview(label)
            label.snp.makeConstraints { $0.edges.equalTo(snp.margins) }
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
    
    let dates: [DateView] = (1...31).map { number in return DateView().configure { $0.label.text = "\(number)" } }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        let date = dates.first!
        contentView.addSubview(date)
        date.snp.makeConstraints { $0.edges.equalTo(contentView.snp.margins) }
    }
}
