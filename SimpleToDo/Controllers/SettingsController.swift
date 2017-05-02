//
//  SettingsController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

final class SettingsController : UIViewController {
	let viewModel: SettingsViewModel
	let bag = DisposeBag()
	
	let tableView: UITableView = {
		let table = Theme.Controls.tableView()
		
		table.register(DefaultCell.self, forCellReuseIdentifier: "Default")
		table.register(SwitchCell.self, forCellReuseIdentifier: "Switch")
		
		return table
	}()
	
	init(viewModel: SettingsViewModel) {
		self.viewModel = viewModel
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(tableView)
		
		title = viewModel.title
		view.backgroundColor = Theme.Colors.white
		
		tableView.snp.makeConstraints {
			$0.top.equalTo(view.snp.topMargin)
			$0.leading.equalTo(view.snp.leading)
			$0.trailing.equalTo(view.snp.trailing)
			$0.bottom.equalTo(view.snp.bottomMargin)
		}
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
		
		bind()
	}
	
	func bind() {
		viewModel.sections
			.observeOn(MainScheduler.instance)
			.bindTo(tableView.rx.items(dataSource: viewModel.dataSource))
			.disposed(by: bag)
		
		viewModel.errors.subscribe().disposed(by: bag)
		
		tableView.rx.setDelegate(viewModel.tableViewDelegate).disposed(by: bag)
	}
	
	func done() {
		viewModel.done()
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		tableView.snp.updateConstraints {
			$0.top.equalTo(view.snp.topMargin)
			$0.leading.equalTo(view.snp.leading)
			$0.trailing.equalTo(view.snp.trailing)
			$0.bottom.equalTo(view.snp.bottomMargin)
		}
	}
}
