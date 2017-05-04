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
import RxDataSources

final class SettingsController : UIViewController {
	let viewModel: SettingsViewModel
	let bag = DisposeBag()
	
	let dataSource = RxTableViewSectionedReloadDataSource<SettingsSection>()
	let tableViewDelegate = SettingsTableViewDelegate()
	
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
		
		configureDataSource()
		bind()
	}
	
	func bind() {
		viewModel.sections
			.observeOn(MainScheduler.instance)
			.bindTo(tableView.rx.items(dataSource: dataSource))
			.disposed(by: bag)
		
		viewModel.errors.subscribe().disposed(by: bag)
		
		tableView.rx.setDelegate(tableViewDelegate).disposed(by: bag)
	}
	
	func done() {
		viewModel.done()
	}
	
	func configureDataSource() {
		dataSource.configureCell = { [weak viewModel] ds, tv, ip, item in
			
			switch item {
			case .info(let data):
				let cell = tv.dequeueReusableCell(withIdentifier: "Default", for: ip) as! DefaultCell
				SettingsController.configure(cell: cell)
				SettingsController.configure(defaultCell: cell, with: data)
				cell.tapped = { print("about tapped") }
				return cell
			case .deleteAccount(let data):
				let cell = tv.dequeueReusableCell(withIdentifier: "Default", for: ip) as! DefaultCell
				SettingsController.configure(cell: cell)
				SettingsController.configure(defaultCell: cell, with: data)
				cell.tapped = { print("deleteAccount tapped") }
				return cell
			case .exit(let data):
				let cell = tv.dequeueReusableCell(withIdentifier: "Default", for: ip) as! DefaultCell
				SettingsController.configure(cell: cell)
				SettingsController.configure(defaultCell: cell, with: data)
				cell.tapped = { viewModel?.askForLogOff(sourceView: cell) }
				return cell
			case .pushNotificationsSwitch(let data):
				let cell = tv.dequeueReusableCell(withIdentifier: "Switch", for: ip) as! SwitchCell
				SettingsController.configure(cell: cell)
				SettingsController.configure(switchCell: cell, with: data)
				
				cell.switchView.setOn(viewModel?.isPushNotificationsEnabled ?? false, animated: false)
				cell.switchView.isEnabled = viewModel?.isPushNotificationsAllowed ?? false
				cell.switchChanged = { isOn in viewModel?.isPushNotificationsEnabled = isOn }
				
				return cell
			}
		}
	}
	
	static func configure(cell: UITableViewCell) {
		cell.preservesSuperviewLayoutMargins = false
		cell.layoutMargins = .zero
		cell.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		cell.selectionStyle = .none
	}
	
	static func configure(defaultCell cell: DefaultCell, with data: (title: String, image: UIImage)) {
		cell.textLabel?.text = data.title
		cell.imageView?.image = data.image.resize(toWidth: 22)
		cell.accessoryType = .disclosureIndicator
		cell.tintColor = Theme.Colors.pumkin
	}
	
	static func configure(switchCell cell: SwitchCell, with data: (title: String, image: UIImage)) {
		cell.textLabel?.text = data.title
		cell.imageView?.image = data.image.resize(toWidth: 22)
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

final class SettingsTableViewDelegate : NSObject, UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = UIView()
		header.backgroundColor = UIColor.clear
		return header
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? DefaultCell else { return }
		
		cell.tapped?()
	}
}
