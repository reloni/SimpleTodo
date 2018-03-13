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
        picker.dataSource = self
        picker.delegate = self
        picker.snp.makeConstraints {
            $0.edges.equalTo(contentView.snp.edges)
        }
//        contentView.snp.makeConstraints { $0.height.equalTo(150) }
        contentView.clipsToBounds = true
    }
}

extension PickerCell: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension PickerCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
}
