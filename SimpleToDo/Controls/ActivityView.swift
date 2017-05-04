//
//  ActivityView.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 04.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import SnapKit

final class ActivityView: UIView {
	let spinner: UIActivityIndicatorView = {
		return UIActivityIndicatorView(activityIndicatorStyle: .gray)
	}()
	
	let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
	
	init() {
		super.init(frame: CGRect.zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {		
		backgroundColor = Theme.Colors.clear

		addSubview(spinner)
		insertSubview(blurView, belowSubview: spinner)
		spinner.snp.makeConstraints {
			$0.center.equalTo(snp.center)
		}
		blurView.snp.makeConstraints {
			$0.edges.equalTo(snp.edges)
		}
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		spinner.snp.updateConstraints {
			$0.center.equalTo(snp.center)
		}
		blurView.snp.updateConstraints {
			$0.edges.equalTo(snp.edges)
		}
	}
}
