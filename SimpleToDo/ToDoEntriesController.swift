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

final class ToDoEntriesController : UIViewController {
	let bag = DisposeBag()
	
	let dataSource = RxTableViewSectionedAnimatedDataSource<ToDoEntrySection>()
	
	let tableView: UITableView = {
		let table = UITableView()
		table.preservesSuperviewLayoutMargins = false
		table.separatorInset = .zero
		table.contentInset = .zero
		//table.allowsMultipleSelectionDuringEditing = false
		table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
		
		self.view.backgroundColor = UIColor.white
		
		title = "To do"
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewEntry))
		
		tableView.refreshControl = UIRefreshControl()
		
		view.addSubview(tableView)
		view.addSubview(addButton)
		
		dataSource.configureCell = { ds, tv, ip, item in
			let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip)
			cell.separatorInset = .zero
			cell.layoutEdgeInsets = .zero
			cell.textLabel?.text = "Item \(item.id): \(item.description) - \(item.completed)"
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
		
		tableView.rx.itemSelected.subscribe(onNext: { path in
			appState.dispatch(AppAction.showEditEntryController(appState.stateValue.state.toDoEntries[path.row]))
		}).addDisposableTo(bag)
		
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
}
