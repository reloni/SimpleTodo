//
//  ToDoEntriesController.swift
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
import Material
import RxHttpClient
import AMScrollingNavbar

final class ToDoEntriesController : UIViewController {
	let bag = DisposeBag()
	
	let dataSource = RxTableViewSectionedAnimatedDataSource<ToDoEntrySection>()
	
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
	
	let addButton: Button = {
		let button = Button()
		button.backgroundColor = UIColor.cyan
		button.title = "Add item"
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let navigationController = navigationController as? ScrollingNavigationController {
			navigationController.followScrollView(tableView, delay: 50.0)
		}
		
		self.view.backgroundColor = UIColor.white
		
		title = "To do"
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewEntry))
		
		tableView.refreshControl = UIRefreshControl()
		
		view.addSubview(tableView)
		view.addSubview(addButton)
		
		dataSource.configureCell = { ds, tv, ip, item in
			let cell = tv.dequeueReusableCell(withIdentifier: "TaskCell", for: ip) as! TaskCell
			cell.separatorInset = .zero
			cell.layoutEdgeInsets = .zero
			cell.selectionStyle = .none
			cell.isExpanded = false
			cell.taskDescription.text = "Item \(item.id): \(item.description) - \(item.completed)"
			
			cell.completeTapped = {
				print("row \(ip.row) complete")
			}
			
			cell.editTapped = {
				guard let row = tv.indexPath(for: cell)?.row else { return }
				appState.dispatch(AppAction.showEditEntryController(appState.stateValue.state.toDoEntries[row]))
			}
			
			cell.deleteTapped = {
				guard let row = tv.indexPath(for: cell)?.row else { return }
				appState.dispatch(AppAction.deleteToDoEntry(row))
			}
			return cell
		}
		dataSource.canEditRowAtIndexPath = { _ in
			return true
		}
		dataSource.canMoveRowAtIndexPath = { _ in
			return true
		}
		
		updateViewConstraints()
		
		bind()
		
		appState.dispatch(AppAction.loadToDoEntries)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
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
		appState.state.filter {
			switch $0.setBy {
			case AppAction.addToDoEntry: fallthrough
			case AppAction.deleteToDoEntry: fallthrough
			case AppAction.loadToDoEntries: fallthrough
			case AppAction.updateEntry: fallthrough
			case AppAction.reloadToDoEntries: return true
			default: return false
			}
			}
			.flatMap { newState ->  Observable<[ToDoEntrySection]> in
				return Observable.just([ToDoEntrySection(header: "test", items: newState.state.toDoEntries)])
			}
			.observeOn(MainScheduler.instance)
			.do(onNext: { [weak self] _ in self?.tableView.refreshControl?.endRefreshing() })
			.startWith([])
			.bindTo(tableView.rx.items(dataSource: dataSource))
			.addDisposableTo(bag)
		
		tableView.refreshControl?.rx.controlEvent(.valueChanged).filter { [weak self] in self?.tableView.refreshControl?.isRefreshing ?? false }
			.subscribe(onNext: {
					appState.dispatch(AppAction.loadToDoEntries)
			}).addDisposableTo(bag)
		
//		tableView.rx.itemDeleted.subscribe(onNext: { path in
//			appState.dispatch(AppAction.deleteToDoEntry(path.row))
//		}).addDisposableTo(bag)
		
//		tableView.rx.itemMoved.subscribe(onNext: { p in
//			print("item moved")
//		}).addDisposableTo(bag)
		
//		tableView.rx.itemSelected.subscribe(onNext: { path in
//			appState.dispatch(AppAction.showEditEntryController(appState.stateValue.state.toDoEntries[path.row]))
//		}).addDisposableTo(bag)
		
		appState.errors.subscribe(onNext: {
			appState.dispatch(AppAction.showAllert(in: self, with: $0.error))
		}).addDisposableTo(bag)
		
		tableView.rx.setDelegate(self).addDisposableTo(bag)
	}
	
	func addNewEntry() {
		appState.dispatch(AppAction.showEditEntryController(nil))
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		tableView.snp.remakeConstraints { make in
			make.top.equalTo(view.snp.top).offset(0)
			make.leading.equalTo(view.snp.leading)
			make.trailing.equalTo(view.snp.trailing)
			make.bottom.equalTo(view.snp.bottom).offset(-40)
		}
		
		addButton.snp.remakeConstraints { make in
			make.top.equalTo(tableView.snp.bottom).offset(10)
			make.leading.equalTo(view.snp.leading).offset(20)
			make.trailing.equalTo(view.snp.trailing).offset(-20)
			make.bottom.equalTo(view.snp.bottom).offset(-10)
		}
	}
}

extension ToDoEntriesController : UITableViewDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
			tableView.setEditing(false, animated: true)
			appState.dispatch(AppAction.showEditEntryController(appState.stateValue.state.toDoEntries[index.row]))
		}
		edit.backgroundColor = UIColor.lightGray
		
		let custom = UITableViewRowAction(style: .normal, title: "Custom") { action, index in
			tableView.setEditing(false, animated: true)
			let entry = appState.stateValue.state.toDoEntries[index.row]
			let changed = ToDoEntry(id: entry.id, completed: !entry.completed, description: entry.description, notes: entry.notes)
			appState.dispatch(AppAction.updateEntry(changed))
		}
		custom.backgroundColor = UIColor.orange
		
		let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
			appState.dispatch(AppAction.deleteToDoEntry(index.row))
		}
		delete.backgroundColor = UIColor.red
		
		return [delete, edit, custom]
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return UITableViewCellEditingStyle.delete
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return }
		UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
			tableView.beginUpdates()
			cell.isExpanded = !cell.isExpanded
			tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
			tableView.endUpdates()
		}.startAnimation()
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell
			else { return }		
		UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
			tableView.beginUpdates()
			cell.isExpanded = false
			tableView.endUpdates()
			}.startAnimation()
	}
}
