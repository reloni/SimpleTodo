//
//  CustomTaskRepeatModeController.swift
//  Aika
//
//  Created by Anton Efimenko on 13.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit
import RxSwift

final class CustomTaskRepeatModeController: UIViewController {
	let viewModel: CustomTaskRepeatModeViewModel
	
	init(viewModel: CustomTaskRepeatModeViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Setup"
		
		view.backgroundColor = Theme.Colors.isabelline
	}
}
