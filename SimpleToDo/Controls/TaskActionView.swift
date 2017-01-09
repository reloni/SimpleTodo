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
		lbl.font = UIFont.systemFont(ofSize: UIFont.systemFontSize - 3)
		return lbl
	}()
	
	let imageView: UIImageView = {
		let img = UIImageView()
		img.contentMode = .scaleAspectFit
		return img
	}()
	
	init(text: String, image: UIImage? = nil) {
		super.init(frame: .zero)
		
		addSubview(actionLabel)
		addSubview(imageView)
		
		actionLabel.text = text
		imageView.image = image
		
		imageView.snp.makeConstraints { makeActionImageConstraints(maker: $0) }
		
		actionLabel.snp.makeConstraints { makeActionLabelConstraints(maker: $0) }
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func makeActionLabelConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(self.snp.top)
		maker.leading.equalTo(imageView.snp.trailing).offset(10)
		maker.trailing.equalTo(self.snp.trailing).offset(-10)
		maker.height.equalTo(self.snp.height)
	}
	
	func makeActionImageConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(self.snp.top)
		maker.leading.equalTo(self.snp.leading).offset(10)
		maker.height.equalTo(self.snp.height)
		maker.width.equalTo(imageView.snp.height)
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		
		imageView.snp.updateConstraints { makeActionImageConstraints(maker: $0) }
		actionLabel.snp.updateConstraints { makeActionLabelConstraints(maker: $0) }
	}
}
