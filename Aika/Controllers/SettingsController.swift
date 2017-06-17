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
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: bag)
		
		viewModel.errors.subscribe().disposed(by: bag)
		
		tableView.rx.setDelegate(tableViewDelegate).disposed(by: bag)
	}
	
	func done() {
		viewModel.done()
	}
	
	func configureDataSource() {
		dataSource.configureCell = { [weak self] ds, tv, ip, item in
			
			switch item {
			case .frameworks(let data):
				let cell = SettingsController.dequeueAndConfigureDefaultCell(for: ip, with: data, in: tv)
				cell.tapped = { self?.viewModel.showFramwrorks() }
				return cell
			case .deleteAccount(let data):
				let cell = SettingsController.dequeueAndConfigureDefaultCell(for: ip, with: data, in: tv)
				cell.tapped = { self?.viewModel.askForDeleteUser(sourceView: cell) }
				return cell
			case .exit(let data):
				let cell = SettingsController.dequeueAndConfigureDefaultCell(for: ip, with: data, in: tv)
				cell.tapped = { self?.viewModel.askForLogOff(sourceView: cell) }
				return cell
			case .deleteLocalCache(let data):
				let cell = SettingsController.dequeueAndConfigureDefaultCell(for: ip, with: data, in: tv)
				cell.tapped = { self?.viewModel.askForDeleteCache(sourceView: cell) }
				return cell
			case .sourceCode(let data):
				let cell = SettingsController.dequeueAndConfigureDefaultCell(for: ip, with: data, in: tv)
				cell.tapped = { UIApplication.shared.open(URL(string: "https://github.com/reloni/SimpleTodo")!) }
				return cell
			case .text(let data):
				let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "value1")
				SettingsController.configure(cell: cell)
				SettingsController.configureTextCell(cell, with: data)
				return cell
			case .pushNotificationsSwitch(let data):
				let cell = SwitchCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Switch")
				SettingsController.configure(cell: cell)
				SettingsController.configure(switchCell: cell, with: data)
				
				cell.switchView.setOn(self?.viewModel.isPushNotificationsEnabled ?? false, animated: false)
				if let object = self {
					object.viewModel.isPushNotificationsAllowed.bind(to: cell.switchView.rx.isEnabled).disposed(by: object.bag)
				}

				cell.switchChanged = { isOn in self?.viewModel.isPushNotificationsEnabled = isOn }
				
				return cell
			}
		}
		
		dataSource.titleForHeaderInSection = { ds, index in
			return ds.sectionModels[index].header
			
		}
	}
	
	static func dequeueAndConfigureDefaultCell(for indexPath: IndexPath, with data: (title: String, image: UIImage), in table: UITableView) -> DefaultCell {
		let cell = table.dequeueReusableCell(withIdentifier: "Default", for: indexPath) as! DefaultCell
		SettingsController.configure(cell: cell)
		SettingsController.configure(defaultCell: cell, with: data)
		return cell
	}
	
	static func configure(cell: UITableViewCell) {
		cell.preservesSuperviewLayoutMargins = false
		cell.layoutMargins = .zero
		cell.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		cell.selectionStyle = .none
	}
	
	static func configureTextCell(_ cell: UITableViewCell, with data: (title: String, value: String, image: UIImage?)) {
		cell.textLabel?.text = data.title
		cell.imageView?.image = data.image?.resize(toWidth: 22)
		cell.detailTextLabel?.text = data.value
		cell.tintColor = Theme.Colors.pumkin
	}
	
	static func configure(defaultCell cell: DefaultCell, with data: (title: String, image: UIImage)) {
		cell.textLabel?.text = data.title
		cell.imageView?.image = data.image.resize(toWidth: 22)
		cell.accessoryType = .disclosureIndicator
		cell.accessoryView = UIImageView(image: Theme.Images.accessoryArrow)
		cell.tintColor = Theme.Colors.pumkin
	}
	
	static func configure(switchCell cell: SwitchCell, with data: (title: String, subtitle: String?, image: UIImage)) {
		cell.textLabel?.text = data.title
		cell.detailTextLabel?.text = data.subtitle
		cell.detailTextLabel?.textColor = Theme.Colors.romanSilver
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
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		(view as? UITableViewHeaderFooterView)?.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = UITableViewHeaderFooterView()
		return header
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? DefaultCell else { return }
		
		cell.tapped?()
	}
}
