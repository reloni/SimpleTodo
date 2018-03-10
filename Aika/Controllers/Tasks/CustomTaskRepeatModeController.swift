//
//  CustomTaskRepeatModeController.swift
//  Aika
//
//  Created by Anton Efimenko on 13.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

final class CustomTaskRepeatModeController: UIViewController {
	let bag = DisposeBag()
	let viewModel: CustomTaskRepeatModeViewModel
    lazy var tableViewDelegate: CustomTaskRepeatModeTableViewDelegate = {
       return CustomTaskRepeatModeTableViewDelegate(viewModel: self.viewModel)
    }()
	
	lazy var dataSource: RxTableViewSectionedAnimatedDataSource<CustomTaskRepeatModeSection> = {
        let animationConfiguration = AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .bottom)
        
        return RxTableViewSectionedAnimatedDataSource<CustomTaskRepeatModeSection>(
            animationConfiguration: animationConfiguration,
            configureCell: { [weak self] ds, tv, ip, item in
                let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
                cell.textLabel?.text = item.mainText
                cell.detailTextLabel?.text = item.detailText
                cell.selectionStyle = .none
                return cell
            },
            canEditRowAtIndexPath: { _, _ in return false })
	}()
	
	let tableView = Theme.Controls.tableView().configure {
		$0.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 40, right: 0)
	}
	
	init(viewModel: CustomTaskRepeatModeViewModel) {
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
}


final class CustomTaskRepeatModeTableViewDelegate : NSObject, UITableViewDelegate {
    let viewModel: CustomTaskRepeatModeViewModel
    
    init(viewModel: CustomTaskRepeatModeViewModel) {
        self.viewModel = viewModel
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? DefaultCell else { return }
//
//        cell.tapped?()
        print("tapped")
        viewModel.updateSections()
    }
}