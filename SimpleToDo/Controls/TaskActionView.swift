//
//  TaskActionView.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 09.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import SnapKit
import UIKit

final class TaskActonView : UIView {
	let actionLabel: UILabel = {
		let lbl = UILabel()
		lbl.font = Theme.Fonts.accesory
		return lbl
	}()
	
	let imageView: UIImageView = {
		let img = UIImageView()
		img.contentMode = .scaleAspectFit
		return img
	}()
	
	let wrapper: UIView = {
		return UIView()
	}()
	
	let expandHeight: CGFloat
	
	init(text: String, image: UIImage? = nil, expandHeight: CGFloat = 0) {
		self.expandHeight = expandHeight
		
		super.init(frame: .zero)
		
		addSubview(wrapper)
		wrapper.addSubview(actionLabel)
		wrapper.addSubview(imageView)
		
		actionLabel.text = text
		imageView.image = image
		
		wrapper.snp.makeConstraints { makeWrapperConstraints(maker: $0) }
		imageView.snp.makeConstraints { makeActionImageConstraints(maker: $0) }
		actionLabel.snp.makeConstraints { makeActionLabelConstraints(maker: $0) }
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func makeWrapperConstraints(maker: ConstraintMaker) {
		maker.centerX.equalTo(snp.centerX)
		maker.centerY.equalTo(snp.centerY)
		maker.height.equalTo(snp.height)
	}
	
	func makeActionLabelConstraints(maker: ConstraintMaker) {
		maker.centerY.equalTo(wrapper.snp.centerY)
		maker.leading.equalTo(imageView.snp.trailing).offset(10)
		maker.trailing.equalTo(wrapper.snp.trailing).offset(-10)
		maker.height.equalTo(wrapper.snp.height)
	}
	
	func makeActionImageConstraints(maker: ConstraintMaker) {
		maker.centerY.equalTo(wrapper.snp.centerY)
		maker.leading.equalTo(wrapper.snp.leading).offset(10)
		maker.height.equalTo(wrapper.snp.height).multipliedBy(0.7)
		maker.width.equalTo(expandHeight * 0.7)
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		
		wrapper.snp.updateConstraints { makeWrapperConstraints(maker: $0) }
		imageView.snp.updateConstraints { makeActionImageConstraints(maker: $0) }
		actionLabel.snp.updateConstraints { makeActionLabelConstraints(maker: $0) }
	}
}
