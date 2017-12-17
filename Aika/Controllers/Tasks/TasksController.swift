//
//  TasksController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 17.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Material
import SnapKit

final class TasksController : UIViewController {
	let bag = DisposeBag()

	let viewModel: TasksViewModel
	let tableViewDelegate = TasksTableViewDelegate()
	lazy var dataSource: RxTableViewSectionedAnimatedDataSource<TaskSection> = {
		let configureCell = { [unowned self] ds, tv, ip, item in
			TasksController.configureCell(dataSource: ds, tableView: tv, indexPath: ip, item: item, viewController: self)
		}
		return RxTableViewSectionedAnimatedDataSource<TaskSection>(animationConfiguration: AnimationConfiguration(insertAnimation: .left, reloadAnimation: .fade, deleteAnimation: .right),
		                                                    configureCell: configureCell,
		                                                    canEditRowAtIndexPath: { _, _ in return true })
	}()
	
	let tableView: UITableView = {
		let table = Theme.Controls.tableView()
		
		table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 75, right: 0)
		table.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
		
		return table
	}()
	
	let addTaskButton: FABButton = {
		let button = FABButton(image: Theme.Images.add.resize(toWidth: 55))
		button.contentEdgeInsets = UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15)
		button.pulseColor = Theme.Colors.white
		button.backgroundColor = Theme.Colors.white
		return button
	}()

	init(viewModel: TasksViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.refreshControl?.endRefreshing()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(tableView)
		view.addSubview(addTaskButton)
		
		view.backgroundColor = UIColor.white
		view.layoutEdgeInsets = .zero
		
		title = viewModel.title
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: Theme.Images.settings.resize(toWidth: 22),
		                                                    style: .plain,
		                                                    target: self,
		                                                    action: #selector(showSettings))
		
		
		tableView.refreshControl = UIRefreshControl()
	
		tableView.snp.makeConstraints(tableViewConstraints)
		addTaskButton.snp.makeConstraints(addTaskButtonConstraints)
		
		bind()

		viewModel.synchronize()
	}
	
	func bind() {
		let sectionsObservable = viewModel.taskSections.share(replay: 1, scope: .forever)
		
		sectionsObservable
			.observeOn(MainScheduler.instance)
			.do(onNext: { [weak self] _ in self?.tableView.refreshControl?.endRefreshing() })
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: bag)
		
		sectionsObservable
			.observeOn(MainScheduler.instance)
			.map { $0.first?.items.count == 0 ? TasksTableBackground() : nil }
			.subscribe(onNext: { [weak self] background in self?.tableView.backgroundView = background })
			.disposed(by: bag)
		
		tableView.refreshControl?.rx.controlEvent(.valueChanged)
			.filter { [weak self] in self?.tableView.refreshControl?.isRefreshing ?? false }
			.subscribe(onNext: { [weak self] in
				self?.viewModel.synchronize()
			}).disposed(by: bag)
		
		viewModel.errors
			.observeOn(MainScheduler.instance)
			.do(onNext: { [weak self] _ in self?.tableView.refreshControl?.endRefreshing() })
			.subscribe()
			.disposed(by: bag)
		
		tableView.rx.setDelegate(tableViewDelegate).disposed(by: bag)
		
		addTaskButton.rx.tap.subscribe { [weak self] _ in self?.viewModel.newTask() }.disposed(by: bag)
	}
	
	@objc func showSettings() {
		viewModel.showSettings()
	}
	
	static func configureCell(dataSource ds: TableViewSectionedDataSource<TaskSection>,
							  tableView tv: UITableView,
							  indexPath ip: IndexPath,
							  item: TaskSection.Item,
							  viewController controller: TasksController) -> UITableViewCell {
		let cell = tv.dequeueReusableCell(withIdentifier: "TaskCell", for: ip) as! TaskCell
		cell.preservesSuperviewLayoutMargins = false
		cell.layoutMargins = .zero
		cell.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		cell.selectionStyle = .none
		cell.isUserInteractionEnabled = true
		cell.isExpanded = ip == controller.tableViewDelegate.currentExpandedIndexPath
		cell.taskDescription.text = "\(item.description)"
		cell.targetDate.attributedText = item.targetDate?.toAttributedString(withSpelling: true)
		cell.repeatImage.isHidden = item.prototype.repeatPattern == nil
		cell.updateConstraints()
		
		cell.completeTapped = { [weak controller] in
			controller?.tableViewDelegate.currentExpandedIndexPath = nil
			controller?.viewModel.completeTask(uuid: item.uuid)
		}
		
		cell.editTapped = { [weak controller] in
			controller?.tableViewDelegate.currentExpandedIndexPath = nil
			controller?.viewModel.editTask(uuid: item.uuid)
		}
		
		cell.deleteTapped = { [weak controller] in
			controller?.tableViewDelegate.currentExpandedIndexPath = nil
			controller?.showDeleteTaskAlert(sourceView: cell.deleteActionView, taskUuid: item.uuid)
		}
		
		return cell
	}
	
	func showDeleteTaskAlert(sourceView: UIView, taskUuid: UUID) {
		let deleteHandler: ((UIAlertAction) -> Void)? = { _ in self.viewModel.deleteTask(forUuid: taskUuid) }
		let actions = [UIAlertAction(title: "Delete task", style: .destructive, handler: deleteHandler),
		               UIAlertAction(title: "Cancel", style: .cancel, handler: nil)]
		
		viewModel.showWarning(in: self, title: nil, message: nil, actions: actions, sourceView: sourceView)
	}
	
	func tableViewConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(view.snp.topMargin)
		maker.leading.equalTo(view.snp.leading)
		maker.trailing.equalTo(view.snp.trailing)
		maker.bottom.equalTo(view.snp.bottomMargin)
	}
	
	func addTaskButtonConstraints(maker: ConstraintMaker) {
		maker.leading.equalTo(view.snp.leading).offset(20)
		maker.bottom.equalTo(view.snp.bottomMargin).offset(-20)
		maker.height.equalTo(45)
		maker.width.equalTo(45)
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		tableView.snp.updateConstraints(tableViewConstraints)
		addTaskButton.snp.updateConstraints(addTaskButtonConstraints)
	}
}

final class TasksTableViewDelegate : NSObject, UITableViewDelegate {
	var currentExpandedIndexPath: IndexPath? = nil
	@available(iOS 11.0, *)
	static func createAction(title: String, backgroundColor: UIColor, image: UIImage?, completionHandler: @escaping () -> Bool) -> UIContextualAction {
		let action = UIContextualAction(style: .normal,
		                                title: title,
		                                handler: { _, _, completion in completion(completionHandler()) })
		action.backgroundColor = backgroundColor
		action.image = image
		return action
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return }

		if !cell.isExpanded {
			currentExpandedIndexPath = indexPath
		} else {
			currentExpandedIndexPath = nil
		}
		
		cell.isExpanded = !cell.isExpanded
		
		animateCellExpansion(tableView: tableView)
	}

	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return }

		cell.isExpanded = false
	}

	func animateCellExpansion(tableView: UITableView) {
		tableView.beginUpdates()
		tableView.endUpdates()
		tableView.scrollToNearestSelectedRow(at: .none, animated: true)
	}
	
	@available(iOS 11.0, *)
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return nil }
		
		let deleteAction = TasksTableViewDelegate.createAction(title: "Delete",
		                                                       backgroundColor: Theme.Colors.upsdelRed,
		                                                       image: Theme.Images.delete.tint(with: .white)!.resize(toWidth: 22),
		                                                       completionHandler: { [weak cell] in cell?.deleteTapped?(); return true })
		let editAction = TasksTableViewDelegate.createAction(title: "Edit",
		                                                       backgroundColor: Theme.Colors.blueberry,
		                                                       image: Theme.Images.edit.tint(with: .white)!.resize(toWidth: 22),
		                                                       completionHandler: { [weak cell] in cell?.editTapped?(); return true })
		return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
	}
	
	@available(iOS 11.0, *)
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return nil }
		
		let completeAction = TasksTableViewDelegate.createAction(title: "Complete",
		                                                     backgroundColor: Theme.Colors.darkSpringGreen,
		                                                     image: Theme.Images.checked.tint(with: .white)!.resize(toWidth: 22),
		                                                     completionHandler: { [weak cell] in cell?.completeTapped?(); return true })
		return UISwipeActionsConfiguration(actions: [completeAction])
	}
}
