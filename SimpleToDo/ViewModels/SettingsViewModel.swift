//
//  SettingsViewModel.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift
import RxDataSources

final class SettingsViewModel {
	let flowController: RxDataFlowController<AppState>
	
	let dataSource = RxTableViewSectionedReloadDataSource<SettingsSection>()
	let tableViewDelegate = SettingsViewModelTableViewDelegate()
	
	var isPushNotificationsEnabled = false
	
	let title = "Settings"
	
	let sections = Observable<[SettingsSection]>.just([SettingsSection(header: "", items: [.pushNotificationsSwitch(title: "Send push notifications", image: Theme.Images.pushNotification!)]),
	                                                   SettingsSection(header: "", items: [.info(title: "About", image: Theme.Images.info!),
	                                                                                             .deleteAccount(title: "Delete account", image: Theme.Images.deleteAccount!),
	                                                                                             .exit(title: "Exit", image: Theme.Images.exit!)])])
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in
			guard let object = self else { return }
			object.flowController.dispatch(UIAction.showError($0.error))
		})
	}()
	
	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
		configureDataSource()
	}
	
	func configureDataSource() {
		dataSource.configureCell = { [weak self] ds, tv, ip, item in
			guard let object = self else { fatalError() }

			switch item {
			case .info(let data):
				let cell = tv.dequeueReusableCell(withIdentifier: "Default", for: ip) as! DefaultCell
				SettingsViewModel.configure(cell: cell)
				SettingsViewModel.configure(defaultCell: cell, with: data)
				cell.tapped = { print("about tapped") }
				return cell
			case .deleteAccount(let data):
				let cell = tv.dequeueReusableCell(withIdentifier: "Default", for: ip) as! DefaultCell
				SettingsViewModel.configure(cell: cell)
				SettingsViewModel.configure(defaultCell: cell, with: data)
				cell.tapped = { print("deleteAccount tapped") }
				return cell
			case .exit(let data):
				let cell = tv.dequeueReusableCell(withIdentifier: "Default", for: ip) as! DefaultCell
				SettingsViewModel.configure(cell: cell)
				SettingsViewModel.configure(defaultCell: cell, with: data)
				cell.tapped = { print("exit tapped") }
				return cell
			case .pushNotificationsSwitch(let data):
				let cell = tv.dequeueReusableCell(withIdentifier: "Switch", for: ip) as! SwitchCell
				SettingsViewModel.configure(cell: cell)
				SettingsViewModel.configure(switchCell: cell, with: data)
				
				cell.switchView.setOn(object.isPushNotificationsEnabled, animated: true)
				cell.switchChanged = { isOn in print("Switch changed: \(isOn)"); object.isPushNotificationsEnabled = isOn }
				
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
	}
	
	static func configure(switchCell cell: SwitchCell, with data: (title: String, image: UIImage)) {
		cell.textLabel?.text = data.title
		cell.imageView?.image = data.image.resize(toWidth: 22)
	}
	
	func save() {
		
	}
	
	func close() {
		flowController.dispatch(UIAction.dismissSettingsController)
	}
}

final class SettingsViewModelTableViewDelegate : NSObject, UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = UIView()
		header.backgroundColor = UIColor.clear
		return header
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return }
		
//		cell.isExpanded = !cell.isExpanded
//		animateCellExpansion(forIndexPath: indexPath, tableView: tableView)
	}
}
