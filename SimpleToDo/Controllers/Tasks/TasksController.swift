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

class TestButton: FABButton {
	override var alignmentRectInsets: UIEdgeInsets { return .zero }
}

final class TasksController : UIViewController {
	let bag = DisposeBag()
	
	let viewModel: TasksViewModel
	let tableViewDelegate = TasksTableViewDelegate()
	let dataSource = RxTableViewSectionedAnimatedDataSource<TaskSection>()
	
	let tableView: UITableView = {
		let table = Theme.Controls.tableView()
		
		table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
		table.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
		
		return table
	}()
	
	let addTaskButton: Button = {
		let button = TestButton(image: Theme.Images.add)
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
		viewModel.taskSections
			.observeOn(MainScheduler.instance)
			.do(onNext: { [weak self] _ in self?.tableView.refreshControl?.endRefreshing() })
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.addDisposableTo(bag)
		
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
		dataSource.configureCell = { ds, tv, ip, item in
			let cell = tv.dequeueReusableCell(withIdentifier: "TaskCell", for: ip) as! TaskCell
			cell.preservesSuperviewLayoutMargins = false
			cell.layoutMargins = .zero
			cell.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
			cell.selectionStyle = .none
			cell.isExpanded = false
			cell.taskDescription.text = "\(item.description)"
			cell.targetDate.attributedText = item.targetDate?.toAttributedString(withSpelling: true)
			cell.updateConstraints()
			
			cell.completeTapped = { [weak self] in
				guard let object = self else { return }
				guard let row = tv.indexPath(for: cell)?.row else { return }
				object.viewModel.completeTask(index: row)
			}
			
			cell.editTapped = { [weak self] in
				guard let object = self else { return }
				guard let row = tv.indexPath(for: cell)?.row else { return }
				object.viewModel.editTask(index: row)
			}
			
			cell.deleteTapped = { [weak self] in
				guard let object = self else { return }
				guard let row = tv.indexPath(for: cell)?.row else { return }
				object.viewModel.deleteTask(index: row)
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
	
	func tableViewConstraints(maker: ConstraintMaker) {
		maker.top.equalTo(view.snp.topMargin)
		maker.leading.equalTo(view.snp.leading)
		maker.trailing.equalTo(view.snp.trailing)
		maker.bottom.equalTo(view.snp.bottomMargin)
	}
	
	func addTaskButtonConstraints(maker: ConstraintMaker) {
		maker.trailing.equalTo(view.snp.trailing).offset(-20)
		maker.bottom.equalTo(view.snp.bottomMargin).offset(-20)
		maker.height.equalTo(55)
		maker.width.equalTo(55)
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
		animateCellExpansion(forIndexPath: indexPath, tableView: tableView)
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return }
		
		cell.isExpanded = false
		animateCellExpansion(forIndexPath: nil, tableView: tableView)
	}
	
	func animateCellExpansion(forIndexPath indexPath: IndexPath?, tableView: UITableView) {
		tableView.beginUpdates()
		tableView.endUpdates()
		
		if let indexPath = indexPath, tableView.numberOfRows(inSection: 0) == indexPath.row + 1 {
			tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
		}
	}
}
