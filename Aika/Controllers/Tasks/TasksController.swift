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
	let dataSource = RxTableViewSectionedAnimatedDataSource<TaskSection>()
	
	let tableView: UITableView = {
		let table = Theme.Controls.tableView()
		
		table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 75, right: 0)
		table.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
		
		return table
	}()
	
	let addTaskButton: FABButton = {
		let button = FABButton(image: Theme.Images.add.resize(toWidth: 50))
		button.contentEdgeInsets = UIEdgeInsets(top: -13, left: -13, bottom: -13, right: -13)
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
		
		configureDataSource()
		bind()
		
		viewModel.synchronize()
	}
	
	func bind() {
		let sectionsObservable = viewModel.taskSections.shareReplay(1)
		
		sectionsObservable
			.observeOn(MainScheduler.instance)
			.do(onNext: { [weak self] _ in self?.tableView.refreshControl?.endRefreshing() })
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.addDisposableTo(bag)
		
		sectionsObservable
			.observeOn(MainScheduler.instance)
			.map { $0.first?.items.count == 0 ? TasksTableBackground() : nil }
			.subscribe(onNext: { [weak self] background in self?.tableView.backgroundView = background })
			.disposed(by: bag)
		
		tableView.refreshControl?.rx.controlEvent(.valueChanged)
			.filter { [weak self] in self?.tableView.refreshControl?.isRefreshing ?? false }
			.subscribe(onNext: { [weak self] in
				self?.viewModel.synchronize()
			}).addDisposableTo(bag)
		
		viewModel.errors
			.observeOn(MainScheduler.instance)
			.do(onNext: { [weak self] _ in self?.tableView.refreshControl?.endRefreshing() })
			.subscribe()
			.addDisposableTo(bag)
		
		tableView.rx.setDelegate(tableViewDelegate).addDisposableTo(bag)
		
		addTaskButton.rx.tap.subscribe { [weak self] _ in self?.addNewTask() }.disposed(by: bag)
	}
	
	func addNewTask() {
		viewModel.newTask()
	}
	
	func showSettings() {
		viewModel.showSettings()
	}
	
	func configureDataSource() {
		dataSource.configureCell = { [weak viewModel, weak self] ds, tv, ip, item in
			let cell = tv.dequeueReusableCell(withIdentifier: "TaskCell", for: ip) as! TaskCell
			cell.preservesSuperviewLayoutMargins = false
			cell.layoutMargins = .zero
			cell.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
			cell.selectionStyle = .none
			cell.isExpanded = false
			cell.taskDescription.text = "\(item.description)"
			cell.targetDate.attributedText = item.targetDate?.toAttributedString(withSpelling: true)
			cell.updateConstraints()
			
			cell.completeTapped = {
				viewModel?.completeTask(uuid: item.uuid)
			}
			
			cell.editTapped = {
				viewModel?.editTask(uuid: item.uuid)
			}
			
			cell.deleteTapped = {
				self?.showDeleteTaskAlert(sourceView: cell.deleteActionView, taskUuid: item.uuid)
			}
			
			return cell
		}
		
		dataSource.canEditRowAtIndexPath = { _ in
			return true
		}
		
		dataSource.canMoveRowAtIndexPath = { _ in
			return true
		}
	}
	
	func showDeleteTaskAlert(sourceView: UIView, taskUuid: UniqueIdentifier) {
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
		maker.height.equalTo(40)
		maker.width.equalTo(40)
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		tableView.snp.updateConstraints(tableViewConstraints)
		addTaskButton.snp.updateConstraints(addTaskButtonConstraints)
	}
}

final class TasksTableViewDelegate : NSObject, UITableViewDelegate {
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return UITableViewCellEditingStyle.delete
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return }
		
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
}
