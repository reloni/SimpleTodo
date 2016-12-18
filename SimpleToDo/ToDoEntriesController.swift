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

struct SectionOfCustomData {
	var header: String
	var items: [Item]
}
extension SectionOfCustomData: AnimatableSectionModelType {
	typealias Item = ToDoEntry
	
	var identity: String {
		return header
	}
	
	init(original: SectionOfCustomData, items: [Item]) {
		self = original
		self.items = items
	}
}

final class ToDoEntriesController : UIViewController {
	let bag = DisposeBag()
	
	let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfCustomData>()
	
	let tableView: UITableView = {
		let table = UITableView()
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
		
		view.addSubview(tableView)
		view.addSubview(addButton)
		
		dataSource.configureCell = { ds, tv, ip, item in
			let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip)
			cell.textLabel?.text = "Item \(item.id): \(item.description) - \(item.completed)"
			return cell
		}
		
		addButton.rx.tap.subscribe(onNext: {
			let newId = (appState.stateValue.state.toDoEntries.last?.id ?? 0) + 1
			_ = appState.dispatch(AddToDoEntryAction(newItem: ToDoEntry(id: newId, completed: false, description: "added 1", notes: nil)))
		}).addDisposableTo(bag)
		
		appState.state.filter { $0.setBy is LoadToDoEntriesAction || $0.setBy is AddToDoEntryAction }
			.flatMap { newState ->  Observable<[SectionOfCustomData]> in
				return Observable.just([SectionOfCustomData(header: "test", items: newState.state.toDoEntries)])
		}
		.observeOn(MainScheduler.instance)
		.bindTo(tableView.rx.items(dataSource: dataSource))
		.addDisposableTo(bag)
		
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
		let credentialData = "john@domain.com:ololo".data(using: String.Encoding.utf8)!.base64EncodedString(options: [])
		let headers = ["Authorization": "Basic \(credentialData)"]
		let request = URLRequest(url: URL(string: "http://localhost:5000/api/todoentries/")!, headers: headers)
		
		appState.dispatch(LoadToDoEntriesAction(httpClient: httpClient, urlRequest: request))?.addDisposableTo(bag)
	}
}
