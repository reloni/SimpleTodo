//
//  TaskRepeatDescriptionView.swift
//  Aika
//
//  Created by Anton Efimenko on 05.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import SnapKit

final class TaskRepeatDescriptionView: UIView {
	let leftLabel: UILabel = {
		let label = Theme.Controls.label(withStyle: .body)
		label.setContentHuggingPriority(UILayoutPriority(rawValue: 751), for: .horizontal)
		label.setContentHuggingPriority(UILayoutPriority(rawValue: 751), for: .vertical)
		label.text = "Repeat"
		return label
	}()
	
	let rightLabel: UILabel = {
		let label = Theme.Controls.label(withStyle: .body)
		label.textColor = Theme.Colors.secondaryLabel
		label.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .horizontal)
		label.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .vertical)
		label.textAlignment = .right
		return label
	}()
	
	let arrowImage: UIImageView = {
		let image = UIImageView(image: Theme.Images.accessoryArrow)
		image.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .vertical)
		image.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
		return image
	}()
	
	init() {
		super.init(frame: CGRect.zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		clipsToBounds = true
		backgroundColor = Theme.Colors.background
		
		addSubview(leftLabel)
		addSubview(rightLabel)
		addSubview(arrowImage)
		
		leftLabel.snp.makeConstraints(makeLeftLabelConstraints(maker:))
		rightLabel.snp.makeConstraints(makeRightLabelConstraints(maker:))
		arrowImage.snp.makeConstraints(makeArrowImageConstraints(maker:))
	}
	
	func makeLeftLabelConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(snp.topMargin).priority(999)
		maker.leading.equalTo(snp.leadingMargin)
		maker.trailing.equalTo(rightLabel.snp.leading).offset(-10)
		maker.bottom.equalTo(snp.bottomMargin)
	}
	
	func makeRightLabelConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(snp.topMargin).priority(999)
		maker.bottom.equalTo(snp.bottomMargin)
		maker.trailing.equalTo(arrowImage.snp.leading).offset(-5)
	}
	
	func makeArrowImageConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(snp.topMargin).priority(999)
		maker.bottom.equalTo(snp.bottomMargin)
		maker.trailing.equalTo(snp.trailingMargin)
		maker.height.equalTo(arrowImage.snp.width)
	}
}
