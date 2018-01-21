//
//  FrameworksController.swift
//  Aika
//
//  Created by Anton Efimenko on 07.06.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxDataSources

final class FrameworksController: UIViewController {
	let viewModel: FrameworksViewModel
	let bag = DisposeBag()
	
	let dataSource = RxTableViewSectionedReloadDataSource<FrameworksSection>(configureCell: FrameworksController.configureCell)
	let tableViewDelegate = FrameworksTableViewDelegate()
	
	let tableView = Theme.Controls.tableView().configure {
		$0.register(DefaultCell.self, forCellReuseIdentifier: "Default")
	}
    
	init(viewModel: FrameworksViewModel) {
		self.viewModel = viewModel
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(tableView)
		
		title = viewModel.title
		view.backgroundColor = Theme.Colors.isabelline
		
		tableView.snp.makeConstraints {
			$0.top.equalTo(view.snp.topMargin)
			$0.leading.equalTo(view.snp.leading)
			$0.trailing.equalTo(view.snp.trailing)
			$0.bottom.equalTo(view.snp.bottomMargin)
		}
		
		bind()
	}
	
	func bind() {
		viewModel.sections
			.observeOn(MainScheduler.instance)
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: bag)
		
		tableView.rx.setDelegate(tableViewDelegate).disposed(by: bag)
	}
	
	static func configureCell(dataSource ds: TableViewSectionedDataSource<FrameworksSection>, tableView tv: UITableView, indexPath ip: IndexPath, item: FrameworkSectionItem) -> UITableViewCell {
		let cell = tv.dequeueReusableCell(withIdentifier: "Default", for: ip) as! DefaultCell
		cell.textLabel?.text = item.name
		cell.accessoryType = .disclosureIndicator
		cell.preservesSuperviewLayoutMargins = false
		cell.layoutMargins = .zero
		cell.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		cell.selectionStyle = .none
		
		cell.tapped = {
			UIApplication.shared.open(item.url)
		}
		
		return cell
	}
}

final class FrameworksTableViewDelegate : NSObject, UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? DefaultCell else { return }
		
		cell.tapped?()
	}
}
