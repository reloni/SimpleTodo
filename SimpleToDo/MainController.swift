//
//  MainController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 01.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//


import UIKit
import SnapKit

final class MainController : UIViewController {
	let label: UILabel = {
		let lbl = UILabel()
		lbl.text = "test"
		return lbl
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		view.addSubview(label)
		
		updateViewConstraints()
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		label.snp.remakeConstraints { make in
			make.top.equalTo(view.snp.top).offset(10)
			make.centerX.equalTo(view.snp.centerX)
		}
	}
}
