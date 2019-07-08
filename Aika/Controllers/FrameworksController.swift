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
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<FrameworksSection> = {
        let configureCell: FrameworksControllerConfigureCell = { [weak self] ds, tv, ip, item -> UITableViewCell in
            guard let vm = self?.viewModel else { return UITableViewCell() }
            return FrameworksController.configureCell(dataSource: ds, tableView: tv, indexPath: ip, item: item, viewModel: vm)
        }
        
        return RxTableViewSectionedReloadDataSource<FrameworksSection>(configureCell: configureCell)
    }()
    
	let tableViewDelegate = FrameworksTableViewDelegate()
	
	let tableView = Theme.Controls.tableView().configure {
		$0.register(TappableCell.self, forCellReuseIdentifier: "Default")
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
		view.backgroundColor = Theme.Colors.background
		
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
	
    static func configureCell(dataSource ds: TableViewSectionedDataSource<FrameworksSection>, tableView tv: UITableView, indexPath ip: IndexPath, item: FrameworkSectionItem, viewModel: FrameworksViewModel) -> UITableViewCell {
		let cell = tv.dequeueReusableCell(withIdentifier: "Default", for: ip) as! TappableCell
		cell.textLabel?.text = item.name
		cell.accessoryType = .disclosureIndicator
		cell.preservesSuperviewLayoutMargins = false
		cell.layoutMargins = .zero
		cell.contentView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		cell.selectionStyle = .none
		
		cell.tapped = { [weak viewModel] in
            viewModel?.openUrl(for: item)
		}
		
		return cell
	}
}

final class FrameworksTableViewDelegate : NSObject, UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? TappableCell else { return }
		
		cell.tapped?()
	}
}
