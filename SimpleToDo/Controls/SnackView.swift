//
//  SnackView.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 05.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

final class SnackView: UIView {
	static let height: CGFloat = 44
	init() {
		super.init(frame: CGRect.zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setup() {
		backgroundColor = Theme.Colors.upsdelRed.withAlphaComponent(0.7)
	}
	
	static func show(in window: UIWindow) {
		let sv = SnackView()
		sv.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
		window.addSubview(sv)
		window.bringSubview(toFront: sv)
		UIView.animate(withDuration: 0.3) {
			sv.frame = CGRect(x: 0, y: window.frame.height - height, width: window.frame.width, height: height)
		}
	}
	
	static func remove(from window: UIWindow) {
		guard let sv = window.subviews.last as? SnackView else { return}
		UIView.animate(withDuration: 0.3, animations: { sv.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height) }, completion: { _ in sv.removeFromSuperview() })
	}
}
