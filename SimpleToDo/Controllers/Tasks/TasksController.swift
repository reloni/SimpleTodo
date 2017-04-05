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
import AMScrollingNavbar

final class TasksController : UIViewController {
	let bag = DisposeBag()

	let viewModel: TasksViewModel

	let tableView: UITableView = {
		let table = UITableView()
		
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

		if let navigationController = navigationController as? ScrollingNavigationController {
			navigationController.followScrollView(tableView, delay: 50.0)
		}
		
		self.view.backgroundColor = UIColor.white
		
		title = viewModel.title
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTask))
		
		tableView.refreshControl = UIRefreshControl()
		
		view.addSubview(tableView)
		
		updateViewConstraints()
		
		bind()
	
		viewModel.loadTasks()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if let navigationController = navigationController as? ScrollingNavigationController {
			navigationController.showNavbar(animated: true)
		}
	}
	
	func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		if let navigationController = navigationController as? ScrollingNavigationController {
			navigationController.showNavbar(animated: true)
		}
		return true
	}
	
	func bind() {
			viewModel.taskSections
			.observeOn(MainScheduler.instance)
			.do(onNext: { [weak self] _ in self?.tableView.refreshControl?.endRefreshing() })
			.startWith([])
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
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		tableView.snp.remakeConstraints { make in
			make.top.equalTo(view.snp.topMargin).offset(0)
			make.leading.equalTo(view.snp.leading)
			make.trailing.equalTo(view.snp.trailing)
			make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
		}
	}
}
