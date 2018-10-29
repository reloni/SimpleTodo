//
//  TaskRepeatModeController.swift
//  Aika
//
//  Created by Anton Efimenko on 05.09.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

final class TaskRepeatModeController: UIViewController {
	let viewModel: TaskRepeatModeViewModel
	let bag = DisposeBag()
	let tableViewDelegate = TaskRepeatModeTableViewDelegate()
	
	lazy var dataSource: RxTableViewSectionedAnimatedDataSource<TaskRepeatModeSection> = {
        let animationConfiguration = AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .bottom)
		return RxTableViewSectionedAnimatedDataSource<TaskRepeatModeSection>(
            animationConfiguration: animationConfiguration,
            configureCell: { [weak self] ds, tv, ip, item in
            if item.isSubtitle {
                let cell = SubtitleCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
                cell.label.text = item.text
                return cell
            }
            
			let cell = tv.dequeueReusableCell(withIdentifier: "Default", for: ip) as! TappableCell

			cell.textLabel?.text = item.text
			if item.isSelected {
				cell.imageView?.image = Theme.Images.checked.resize(toWidth: 22)
			} else {
				cell.imageView?.image = Theme.Images.empty.resize(toWidth: 22)
			}
			cell.preservesSuperviewLayoutMargins = false
			
			cell.selectionStyle = .none
			
			cell.tapped = {
				if item.isCustom {
					self?.viewModel.setCustomMode()
				} else {
					self?.viewModel.setNew(mode: item.mode)
				}
			}
			
			return cell
		})
	}()
	
	let tableView = Theme.Controls.tableView().configure { table in
		table.register(TappableCell.self, forCellReuseIdentifier: "Default")
        table.tableFooterView = UIView()
        table.tableFooterView?.snp.makeConstraints {   
            $0.width.equalTo(table.snp.width)
            $0.height.equalTo(1)
        }
	}
	
	init(viewModel: TaskRepeatModeViewModel) {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            viewModel.close()
        }
    }
	
	func bind() {
		viewModel.sections
			.observeOn(MainScheduler.instance)
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: bag)
		
		tableView.rx.setDelegate(tableViewDelegate).disposed(by: bag)
	}
}

final class TaskRepeatModeTableViewDelegate : NSObject, UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = UITableViewHeaderFooterView()
        header.backgroundView = UIView()
        header.backgroundView?.backgroundColor = Theme.Colors.clear
        return header
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? TappableCell else { return }

		cell.tapped?()
	}
}
