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

final class CustomDataSource<T : AnimatableSectionModelType> : RxTableViewSectionedAnimatedDataSource<T> {
	public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		print("commmit?")
	}
}

final class ToDoEntriesController : UIViewController {
	let bag = DisposeBag()
	
	let dataSource = RxTableViewSectionedAnimatedDataSource<ToDoEntrySection>()
	
	let tableView: UITableView = {
		let table = UITableView()
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
		
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.rx.controlEvent(.valueChanged).filter { [weak self] in self?.tableView.refreshControl?.isRefreshing ?? false }
			.subscribe(onNext: { [weak self] in appState.dispatch(AppAction.loadToDoEntries); self?.tableView.refreshControl?.endRefreshing() }).addDisposableTo(bag)
		
		view.addSubview(tableView)
		view.addSubview(addButton)
		
		dataSource.configureCell = { ds, tv, ip, item in
			let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip)
			cell.textLabel?.text = "Item \(item.id): \(item.description) - \(item.completed)"
			return cell
		}
		dataSource.canEditRowAtIndexPath = { _ in
			return true
		}
		dataSource.canMoveRowAtIndexPath = { _ in
				return true
		}
		
		
		//tableView.delegate = self
		//tableView.dataSource = dataSource
		//tableView.rx.setDelegate(dataSource)
		
		tableView.rx.itemDeleted.subscribe(onNext: { path in
			appState.dispatch(AppAction.deleteToDoEntry(path.row))
		}).addDisposableTo(bag)
		
		tableView.rx.itemMoved.subscribe(onNext: { p in
			print("item moved")
		}).addDisposableTo(bag)
		
		addButton.rx.tap.subscribe(onNext: {
			let newId = (appState.stateValue.state.toDoEntries.last?.id ?? 0) + 1
			appState.dispatch(AppAction.addToDoEntry(ToDoEntry(id: newId, completed: false, description: "added 1", notes: nil)))
		}).addDisposableTo(bag)
		
		appState.state.filter {
			switch $0.setBy {
			case AppAction.addToDoEntry: fallthrough
			case AppAction.deleteToDoEntry: fallthrough
			case AppAction.loadToDoEntries: fallthrough
			case AppAction.reloadToDoEntries: return true
			default: return false
			}
			}
			.flatMap { newState ->  Observable<[ToDoEntrySection]> in
				return Observable.just([ToDoEntrySection(header: "test", items: newState.state.toDoEntries)])
		}
		.observeOn(MainScheduler.instance)
		.bindTo(tableView.rx.items(dataSource: dataSource))
		.addDisposableTo(bag)
		
		appState.errors.subscribe(onNext: { [weak self] e in
			guard case HttpClientError.invalidResponse(let response, _) = e.error else { print("unknown error"); return }
			print("http response code \(response.statusCode)")
			guard let object = self else { return }
			let alert = UIAlertController(title: "Ошибка", message: e.error.localizedDescription, preferredStyle: .alert)
			let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
			alert.addAction(ok)
			object.present(alert, animated: true, completion: nil)
		}).addDisposableTo(bag)
		
		//tableView.rx.setDelegate(self).addDisposableTo(bag)
		//tableView.rx.setDataSource(dataSource).addDisposableTo(bag)
		
		updateViewConstraints()
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		tableView.snp.remakeConstraints { make in
			make.top.equalTo(view.snp.top).offset(20)
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
	
	override func viewWillAppear(_ animated: Bool) {
		appState.dispatch(AppAction.loadToDoEntries)
	}
}

extension ToDoEntriesController : UITableViewDelegate {
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .delete
	}
}
