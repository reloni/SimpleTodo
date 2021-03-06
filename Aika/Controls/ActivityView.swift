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
	let spinnerContainer: UIView = {
		var view = UIView()
		view.backgroundColor = Theme.Colors.gray.withAlphaComponent(0.4)
		view.clipsToBounds = true
		view.layer.cornerRadius = 10
		return view
	}()
	
	let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
		spinner.color = Theme.Colors.background
		return spinner
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

		addSubview(spinnerContainer)
		spinnerContainer.addSubview(spinner)
		insertSubview(blurView, belowSubview: spinnerContainer)
		
		spinnerContainer.snp.makeConstraints {
			$0.center.equalTo(snp.center)
			$0.height.equalTo(80)
			$0.width.equalTo(80)
		}
		
		spinner.snp.makeConstraints {
			$0.center.equalTo(spinnerContainer.snp.center)
		}
		
		blurView.snp.makeConstraints {
			$0.edges.equalTo(snp.edges)
		}
	}
	
	static func show(in window: UIWindow) {
		let av = ActivityView()
		av.frame = window.frame
		window.addSubview(av)
        window.bringSubviewToFront(av)
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
