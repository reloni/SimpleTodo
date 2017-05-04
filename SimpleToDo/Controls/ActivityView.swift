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
	
	let blurView = UIVisualEffectView()
	
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
	
	static func show(in window: UIWindow) {
		let av = ActivityView()
		av.frame = window.frame
		window.addSubview(av)
		window.bringSubview(toFront: av)
		av.spinner.startAnimating()
		UIView.animate(withDuration: 0.3) {
			av.blurView.effect = UIBlurEffect(style: .regular)
		}
	}
	
	static func remove(from window: UIWindow) {
		guard let av = window.subviews.last as? ActivityView else { return}
		UIView.animate(withDuration: 0.3, animations: { av.blurView.effect = nil }, completion: { _ in av.removeFromSuperview() })
	}
}
