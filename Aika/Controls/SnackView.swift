//
//  SnackView.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 05.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

class SnackView: UIView {
	let hideByTouch: Bool
	
	init(hideByTouch: Bool = true) {
		self.hideByTouch = hideByTouch
		super.init(frame: CGRect.zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup() {
		backgroundColor = Theme.Colors.red.withAlphaComponent(0.8)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard hideByTouch, let window = window else { return }
		SnackView.remove(from: window)
	}
	
	static func show(snackView sv: SnackView, in window: UIWindow) {
		remove(from: window)

        window.addSubview(sv)
        window.bringSubviewToFront(sv)
        
        sv.isHidden = true
        
        sv.snp.makeConstraints {
            $0.leading.equalTo(window.snp.leading)
            $0.trailing.equalTo(window.snp.trailing)
            $0.bottom.equalTo(window.snp.bottom)
        }
        
        sv.setNeedsLayout()
        sv.layoutIfNeeded()
        
        sv.frame = CGRect(x: 0, y: sv.frame.origin.y + sv.frame.height, width: sv.frame.width, height: sv.frame.height)
        sv.isHidden = false
        
		UIView.animate(withDuration: 0.4) {
            sv.frame = CGRect(x: 0, y: sv.frame.origin.y - sv.frame.height, width: sv.frame.width, height: sv.frame.height)
		}
	}
	
	static func remove(from window: UIWindow) {
		guard let sv = window.subviews.last as? SnackView else { return}
		UIView.animate(withDuration: 0.4,
		               animations: { sv.frame = CGRect(x: 0, y: sv.frame.origin.y + sv.frame.height, width: sv.frame.width, height: sv.frame.height) },
		               completion: { _ in sv.removeFromSuperview() })
	}
}

class MessageSnackView: SnackView {
	let messageLabel: UILabel = {
		let label = Theme.Controls.label(withStyle: .body)
		label.textColor = Theme.Colors.whiteColor
        label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		label.textAlignment = .center
		label.minimumScaleFactor = 0.5
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	init(message: String, hideByTouch: Bool = true) {
		messageLabel.text = message
        
		super.init(hideByTouch: hideByTouch)
        
        self.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func setup() {
		super.setup()
		
		addSubview(messageLabel)
		
		messageLabel.snp.makeConstraints {
			$0.edges.equalTo(snp.margins)
		}
	}
}
