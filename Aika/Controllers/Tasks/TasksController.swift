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
import SnapKit

final class TasksController : UIViewController {
	let bag = DisposeBag()

	let viewModel: TasksViewModel
	let tableViewDelegate = TasksTableViewDelegate()
    lazy var dataSource: RxTableViewSectionedAnimatedDataSource<TaskSection> = {
        let configureCell: TasksControllerConfigureCell = { [weak self] ds, tv, ip, item -> UITableViewCell in
            guard let controller = self else { return UITableViewCell() }
            return TasksController.configureCell(dataSource: ds, tableView: tv, indexPath: ip, item: item, viewController: controller)
        }
        let animationConfiguration = AnimationConfiguration(insertAnimation: .left, reloadAnimation: .fade, deleteAnimation: .right)

        return RxTableViewSectionedAnimatedDataSource<TaskSection>(animationConfiguration: animationConfiguration,
                                                                   configureCell: configureCell,
                                                                   canEditRowAtIndexPath: { _, _ in return true })
    }()
	
	let tableView = Theme.Controls.tableView().configure {
		$0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 75, right: 0)
		$0.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
	}

    let addTaskButton = UIButton().configure {
        $0.setImage(Theme.Images.add.resize(toWidth: 55), for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15)
        $0.backgroundColor = Theme.Colors.secondaryBackground
    }

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
		
		view.backgroundColor = Theme.Colors.background

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
    
    override func viewWillLayoutSubviews() {
        addTaskButton.layer.cornerRadius = addTaskButton.bounds.height / 2
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
		cell.targetDate.attributedText = item.targetDate?.toAttributedString(format: .relative(withTime: item.targetDate?.includeTime ?? false))
		cell.repeatImage.isHidden = item.prototype.repeatPattern == nil
		cell.setNeedsUpdateConstraints()
		
		cell.completeTapped = { [weak controller] in
			controller?.tableViewDelegate.currentExpandedIndexPath = nil
			controller?.viewModel.completeTask(uuid: item.uuid)
		}
		
		cell.editTapped = { [weak controller] in
			controller?.tableViewDelegate.currentExpandedIndexPath = nil
			controller?.viewModel.editTask(uuid: item.uuid)
		}
		
		cell.deleteTapped = { [weak controller, weak cell] in
			guard let cell = cell else { return }
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
		maker.bottom.equalTo(view.snp.bottom)
	}
	
	func addTaskButtonConstraints(maker: ConstraintMaker) {
		maker.leading.equalTo(view.snp.leading).offset(20)
		maker.bottom.equalTo(view.snp.bottomMargin).offset(-20)
		maker.height.equalTo(45)
		maker.width.equalTo(45)
	}
}

final class TasksTableViewDelegate : NSObject, UITableViewDelegate {
	var currentExpandedIndexPath: IndexPath? = nil

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
		
        animateCellExpansion(tableView: tableView, indexPath: indexPath)
	}

	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return }

		cell.isExpanded = false
	}

    func animateCellExpansion(tableView: UITableView, indexPath: IndexPath) {
		tableView.beginUpdates()
		tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .none, animated: true)
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return nil }
		
		let deleteAction = TasksTableViewDelegate.createAction(title: "Delete",
		                                                       backgroundColor: Theme.Colors.red,
                                                               image: Theme.Images.delete.withTintColor(Theme.Colors.whiteColor).resize(toWidth: 22),
		                                                       completionHandler: { [weak cell] in cell?.deleteTapped?(); return true })
		let editAction = TasksTableViewDelegate.createAction(title: "Edit",
		                                                       backgroundColor: Theme.Colors.tint,
		                                                       image: Theme.Images.edit.withTintColor(Theme.Colors.whiteColor).resize(toWidth: 22),
		                                                       completionHandler: { [weak cell] in cell?.editTapped?(); return true })
		return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
	}
	
	func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return nil }
		
		let completeAction = TasksTableViewDelegate.createAction(title: "Complete",
		                                                     backgroundColor: Theme.Colors.green,
		                                                     image: Theme.Images.checked.withTintColor(Theme.Colors.whiteColor).resize(toWidth: 22),
		                                                     completionHandler: { [weak cell] in cell?.completeTapped?(); return true })
		return UISwipeActionsConfiguration(actions: [completeAction])
	}
}
