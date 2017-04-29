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
	
	let tableView: UITableView = {
		let table = UITableView()
		
		table.cellLayoutMarginsFollowReadableWidth = false
		table.layoutMargins = .zero
		table.preservesSuperviewLayoutMargins = false
		table.separatorInset = .zero
		table.contentInset = .zero
		table.estimatedRowHeight = 50
		table.rowHeight = UITableViewAutomaticDimension
		table.tableFooterView = UIView()
		table.tableFooterView?.backgroundColor = UIColor.lightGray
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
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log off", style: .plain, target: self, action: #selector(logOff))
		
		tableView.refreshControl = UIRefreshControl()
		
		view.addSubview(tableView)
		
		updateViewConstraints()
		
		bind()
		
		viewModel.loadTasks()
	}
	
	func bind() {
		viewModel.taskSections
			.observeOn(MainScheduler.instance)
			.do(onNext: { [weak self] _ in self?.tableView.refreshControl?.endRefreshing() })
			.bindTo(tableView.rx.items(dataSource: viewModel.dataSource))
			.addDisposableTo(bag)
		
		tableView.refreshControl?.rx.controlEvent(.valueChanged).filter { [weak self] in self?.tableView.refreshControl?.isRefreshing ?? false }
			.subscribe(onNext: { [weak self] in
				self?.viewModel.loadTasks()
			}).addDisposableTo(bag)
		
		viewModel.errors.subscribe().addDisposableTo(bag)
		
		tableView.rx.setDelegate(viewModel.tableViewDelegate).addDisposableTo(bag)
	}
	
	func addNewTask() {
		viewModel.newTask()
	}
	
	func logOff() {
		viewModel.logOff()
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
