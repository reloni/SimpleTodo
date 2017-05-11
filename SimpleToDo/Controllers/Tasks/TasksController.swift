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
import Unbox
import RxHttpClient

final class TasksController : UIViewController {
	let bag = DisposeBag()
	
	let viewModel: TasksViewModel
	let tableViewDelegate = TasksTableViewDelegate()
	let dataSource = RxTableViewSectionedAnimatedDataSource<TaskSection>()
	
	let tableView: UITableView = {
		let table = Theme.Controls.tableView()
		
		table.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
		
		return table
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
		
		self.view.backgroundColor = UIColor.white
		
		self.view.layoutEdgeInsets = .zero
		
		title = viewModel.title
		
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTask))
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: Theme.Images.settings.resize(toWidth: 22),
		                                                   style: .plain,
		                                                   target: self, 
		                                                   action: #selector(showSettings))
		
		tableView.refreshControl = UIRefreshControl()
		
		view.addSubview(tableView)
		
		updateViewConstraints()
		
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
			cell.targetDate.text = item.targetDate?.date.longDate
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
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		tableView.snp.remakeConstraints { make in
			make.top.equalTo(view.snp.topMargin)
			make.leading.equalTo(view.snp.leading)
			make.trailing.equalTo(view.snp.trailing)
			make.bottom.equalTo(view.snp.bottomMargin)
		}
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
