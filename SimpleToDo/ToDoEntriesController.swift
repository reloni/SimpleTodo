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
	let items = BehaviorSubject(value: [
		ToDoEntry(id: 55, completed: false, description: "initial 1", notes: nil),
		ToDoEntry(id: 56, completed: false, description: "initial 2", notes: nil),
		ToDoEntry(id: 57, completed: false, description: "initial 3", notes: nil)
		])
	
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
			print("configure cell for row: \(ip.row)")
			let cell = tv.dequeueReusableCell(withIdentifier: "Cell", for: ip)
			cell.textLabel?.text = "Item \(item.id): \(item.description) - \(item.completed)"
			return cell
		}
		
//		addButton.rx.tap.subscribe(onNext: {
//			print("add")
//		}).addDisposableTo(bag)
		
//		addButton.rx.tap.flatMap { _ -> Observable<[SectionOfCustomData]> in
//			print("num of sect: \(self.dataSource.numberOfSections(in: self.tableView))")
//			return Observable.just([SectionOfCustomData(header: "test", items: [ToDoEntry(id: 55, completed: false, description: "added", notes: nil)])])
//			}
//			.bindTo(tableView.rx.items(dataSource: dataSource))
//			.addDisposableTo(bag)

		addButton.rx.tap.subscribe(onNext: {
			var current = try! self.items.value().dropFirst(2)
			current.append(ToDoEntry(id: 55, completed: false, description: "added 1", notes: nil))
			current.append(ToDoEntry(id: 56, completed: false, description: "added 2", notes: nil))
			self.items.onNext(Array(current))
			//return Observable.just(Array(current))
			//print("num of sect: \(self.dataSource.numberOfSections(in: self.tableView))")
			//return Observable.just([SectionOfCustomData(header: "test", items: [ToDoEntry(id: 55, completed: false, description: "added", notes: nil)])])
			})
			.addDisposableTo(bag)
		
		items.flatMap { entries -> Observable<[SectionOfCustomData]> in
			return Observable.just([SectionOfCustomData(header: "test", items: entries)])
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
		
		httpClient.requestData(request).flatMap { result -> Observable<[ToDoEntry]> in
			sleep(2)
			let entries: [ToDoEntry] = try unbox(data: result)
			return Observable.just(entries)
			}.subscribe(onNext: { entries in
				self.items.onNext(entries)
			}).addDisposableTo(bag)
			//.bindTo(items).addDisposableTo(bag)
		
//		httpClient.requestData(request).flatMap { result -> Observable<[SectionOfCustomData]> in
//			sleep(1)
//			let entries: [ToDoEntry] = try unbox(data: result)
//			return Observable.just([SectionOfCustomData(header: "test", items: entries)])
//			}
//		.observeOn(MainScheduler.instance)
//		.bindTo(tableView.rx.items(dataSource: dataSource))
//			.addDisposableTo(bag)
	}
	
}
