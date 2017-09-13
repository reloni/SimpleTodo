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
		label.setContentHuggingPriority(751, for: .horizontal)
		label.setContentHuggingPriority(751, for: .vertical)
		label.text = "Repeat"
		return label
	}()
	
	let rightLabel: UILabel = {
		let label = Theme.Controls.label(withStyle: .body)
		label.textColor = Theme.Colors.romanSilver
		label.setContentHuggingPriority(1, for: .horizontal)
		label.setContentHuggingPriority(1, for: .vertical)
		label.textAlignment = .right
		return label
	}()
	
	let arrowImage: UIImageView = {
		let image = UIImageView(image: Theme.Images.accessoryArrow)
		image.layoutEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
		image.setContentHuggingPriority(999, for: .vertical)
		image.setContentHuggingPriority(999, for: .horizontal)
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
		backgroundColor = Theme.Colors.white
		
		addSubview(leftLabel)
		addSubview(rightLabel)
		addSubview(arrowImage)
		
		leftLabel.snp.makeConstraints(makeLeftLabelConstraints(maker:))
		rightLabel.snp.makeConstraints(makeRightLabelConstraints(maker:))
		arrowImage.snp.makeConstraints(makeArrowImageConstraints(maker:))
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		
		leftLabel.snp.updateConstraints(makeLeftLabelConstraints(maker:))
		rightLabel.snp.updateConstraints(makeRightLabelConstraints(maker:))
		arrowImage.snp.updateConstraints(makeArrowImageConstraints(maker:))
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
