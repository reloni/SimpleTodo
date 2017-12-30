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
import MessageUI

final class SettingsController : UIViewController {
	let viewModel: SettingsViewModel
	let bag = DisposeBag()
	
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SettingsSection> = {
        return RxTableViewSectionedReloadDataSource<SettingsSection>(configureCell: { [weak self] ds, tv, ip, item in
            guard let controller = self else { return UITableViewCell() }
            return SettingsController.configureCell(dataSource: ds, tableView: tv, indexPath: ip, item: item, viewController: controller)
        })
    }()
	
	lazy var tableViewDelegate: SettingsTableViewDelegate = {
		return SettingsTableViewDelegate(dataSource: self.dataSource)
	}()
	
	let tableView: UITableView = {
		let table = Theme.Controls.tableView()
		
		table.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		
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
		
		bind()
		
		viewModel.reloadSections()
	}
	
	func bind() {
		viewModel.sections
			.observeOn(MainScheduler.instance)
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: bag)

		viewModel.errors.subscribe().disposed(by: bag)
		
		tableView.rx.setDelegate(tableViewDelegate).disposed(by: bag)
	}
	
	@objc func done() {
		viewModel.done()
	}
	
	static func configureCell(dataSource ds: TableViewSectionedDataSource<SettingsSection>,
							  tableView tv: UITableView,
							  indexPath ip: IndexPath,
							  item: SettingsSection.Item,
							  viewController controller: SettingsController) -> UITableViewCell {
		weak var ctrl = controller
		switch item {
		case .frameworks(let data):
			let cell = SettingsController.dequeueAndConfigureDefaultCell(for: ip, with: data, in: tv)
			cell.tapped = { [weak controller] in controller?.viewModel.showFramwrorks() }
			return cell
		case .deleteAccount(let data):
			let cell = SettingsController.dequeueAndConfigureDefaultCell(for: ip, with: data, in: tv)
			cell.tapped = { [weak controller, weak cell] in
				guard let cell = cell else { return }
				controller?.showDeleteUserAlert(sourceView: cell)
			}
			return cell
		case .exit(let data):
			let cell = SettingsController.dequeueAndConfigureDefaultCell(for: ip, with: data, in: tv)
			cell.tapped = { [weak controller, weak cell] in
				guard let cell = cell else { return }
				controller?.showLogOffAlert(sourceView: cell)
			}
			return cell
		case .deleteLocalCache(let data):
			let cell = SettingsController.dequeueAndConfigureDefaultCell(for: ip, with: data, in: tv)
			cell.tapped = { [weak controller, weak cell] in
				guard let cell = cell else { return }
				controller?.showDeleteCacheAlert(sourceView: cell)
			}
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
			ctrl?.configure(pushNotificationCell: cell, data: data)
			return cell
		case .email(let data):
			let cell = SettingsController.dequeueAndConfigureDefaultCell(for: ip, with: data, in: tv)
			cell.tapped = { [weak controller] in
				guard let object = controller else { return }
				SettingsController.composeEmail(in: object)
			}
			return cell
		case .iconBadgeStyle(let data):
			let cell = DefaultCell(style: UITableViewCellStyle.value1, reuseIdentifier: "value1")
			SettingsController.configure(cell: cell)
			SettingsController.configureTextCell(cell, with: data)
			cell.accessoryView = UIImageView(image: Theme.Images.accessoryArrow)
			cell.tapped = { [weak controller, weak cell] in
				guard let cell = cell else { return }
				controller?.showBadgeAlert(sourceView: cell)
			}
			return cell
		}
	}
	
	static func composeEmail(in controller: SettingsController) {
		guard MFMailComposeViewController.canSendMail() else { return }
		let mail = MFMailComposeViewController()
		mail.mailComposeDelegate = controller
		mail.setToRecipients(["asefimenko87@gmail.com"])
		mail.setMessageBody("<p></p>", isHTML: true)
		controller.present(mail, animated: true)
	}
	
	func configure(pushNotificationCell cell: SwitchCell, data: (title: String, subtitle: String?, image: UIImage)) {
		SettingsController.configure(cell: cell)
		SettingsController.configure(switchCell: cell, with: data)
		
		cell.switchView.setOn(viewModel.isPushNotificationsEnabled, animated: false)
		viewModel.isPushNotificationsAllowed.bind(to: cell.switchView.rx.isEnabled).disposed(by: bag)
		
		cell.switchChanged = { [weak viewModel] isOn in viewModel?.isPushNotificationsEnabled = isOn }
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
	
	func showLogOffAlert(sourceView: UIView) {
		let logOffHandler: ((UIAlertAction) -> Void)? = { _ in self.viewModel.logOff() }
		let actions = [UIAlertAction(title: "Log off", style: .destructive, handler: logOffHandler),
		               UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]

		viewModel.showWarning(in: self, title: nil, message: nil, actions: actions, sourceView: sourceView)
	}
	
	func showBadgeAlert(sourceView: UIView) {
		let actions = [UIAlertAction(title: IconBadgeStyle.all.description, style: .default, handler: { _ in self.viewModel.updateBadgeStyle(.all) }),
		               UIAlertAction(title: IconBadgeStyle.overdue.description, style: .default, handler: { _ in self.viewModel.updateBadgeStyle(.overdue) }),
		               UIAlertAction(title: IconBadgeStyle.today.description, style: .default, handler: { _ in self.viewModel.updateBadgeStyle(.today) }),
		               UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
		
		viewModel.showWarning(in: self, title: nil, message: nil, actions: actions, sourceView: sourceView)
	}
	
	func showDeleteCacheAlert(sourceView: UIView) {
		let deleteHandler: ((UIAlertAction) -> Void)? = { _ in self.viewModel.deleteCache() }
		let actions = [UIAlertAction(title: "Delete cache", style: .destructive, handler: deleteHandler),
		               UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
		
		viewModel.showWarning(in: self, title: "Warning", message: "Not synchronized data will be lost", actions: actions, sourceView: sourceView)
	}
	
	func showDeleteUserAlert(sourceView: UIView) {
		let deleteHandler: ((UIAlertAction) -> Void)? = { _ in self.viewModel.deleteUser() }
		let actions = [UIAlertAction(title: "Delete user", style: .destructive, handler: deleteHandler),
		               UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
		
		viewModel.showWarning(in: self, title: "Warning", message: "Account and all data will be deleted", actions: actions, sourceView: sourceView)
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

extension SettingsController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
}

final class SettingsTableViewDelegate : NSObject, UITableViewDelegate {
	let dataSource: RxTableViewSectionedReloadDataSource<SettingsSection>
	
	init(dataSource: RxTableViewSectionedReloadDataSource<SettingsSection>) {
		self.dataSource = dataSource
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = TableSectionHeader()
		header.label.text = dataSource.sectionModels[section].header
		header.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
		return header
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? DefaultCell else { return }
		
		cell.tapped?()
	}
}
