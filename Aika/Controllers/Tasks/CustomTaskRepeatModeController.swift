//
//  CustomTaskRepeatModeController.swift
//  Aika
//
//  Created by Anton Efimenko on 13.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class CustomTaskRepeatModeController: UIViewController {
	let bag = DisposeBag()
	let viewModel: CustomTaskRepeatModeViewModel
    lazy var tableViewDelegate: CustomTaskRepeatModeTableViewDelegate = {
       return CustomTaskRepeatModeTableViewDelegate(viewModel: self.viewModel)
    }()
	
	lazy var dataSource: RxTableViewSectionedAnimatedDataSource<CustomTaskRepeatModeSection> = {
        let animationConfiguration = AnimationConfiguration(insertAnimation: .middle, reloadAnimation: .fade, deleteAnimation: .middle)
        
        
        return RxTableViewSectionedAnimatedDataSource<CustomTaskRepeatModeSection>(
            animationConfiguration: animationConfiguration,
            configureCell: { [weak self] ds, tv, ip, item in
                switch item {
                case .placeholder:
                    let cell = PlaceholderCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
                    cell.contentView.backgroundColor = Theme.Colors.isabelline
                    cell.selectionStyle = .none
                    return cell
                case .patternTypePicker:
                    let cell = PickerCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
                    
                    if let controller = self {
                        controller.viewModel.outputs.patternTypetems
                            .bind(to: cell.picker.rx.items(adapter: CustomTaskRepeatModePickerViewViewAdapter()))
                            .disposed(by: cell.bag)
                        
                        cell.picker.rx.modelSelected(Any.self)
                            .subscribe(onNext: { models in
                                print(models)
                            })
                            .disposed(by: cell.bag)
                    }
                    
                    return cell
                case .repeatEveryPicker:
                    let cell = PickerCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
                    
                    if let controller = self {
                        controller.viewModel.outputs.repeatEveryItems
                            .bind(to: cell.picker.rx.items(adapter: CustomTaskRepeatModePickerViewViewAdapter()))
                            .disposed(by: cell.bag)

                        cell.picker.rx.itemSelected
                            .map { $0.row + 1 }
                            .bind(to: controller.viewModel.inputs.repeatEvery)
                            .disposed(by: cell.bag)
                        
                        controller.viewModel.state.map { $0.repeatEvery }.take(1).subscribe(onNext: { [weak cell] repeatEvery in
                            cell?.picker.selectRow(repeatEvery - 1, inComponent: 0, animated: true)
                        }).disposed(by: cell.bag)
                    }
                    
                    return cell
                case .patternType:
                    let cell = TappableCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
                    cell.textLabel?.text = item.mainText
                    cell.detailTextLabel?.text = item.detailText
                    cell.selectionStyle = .none
                    cell.tapped = { [weak self] in self?.patternTypeSelectionToggledSubject.onNext(()) }
                    return cell
                case .repeatEvery:
                    let cell = TappableCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
                    cell.textLabel?.text = item.mainText
                    cell.detailTextLabel?.text = item.detailText
                    cell.selectionStyle = .none
                    cell.tapped = { [weak self] in self?.repeatEverySelectionToggledSubject.onNext(()) }
                    return cell
                }
            },
            canEditRowAtIndexPath: { _, _ in return false })
	}()
    
    let patternTypeSelectionToggledSubject = PublishSubject<Void>()
    let repeatEverySelectionToggledSubject = PublishSubject<Void>()
	
	let tableView = Theme.Controls.tableView().configure {
        $0.estimatedRowHeight = 50
		$0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
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
        
        patternTypeSelectionToggledSubject.withLatestFrom(viewModel.state) { !$1.patternExpanded }
            .bind(to: viewModel.inputs.patternTypeSelected)
            .disposed(by: bag)
        
        repeatEverySelectionToggledSubject.withLatestFrom(viewModel.state) { !$1.repeatEveryExpanded }
            .bind(to: viewModel.inputs.repeatEverySelected)
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
        guard let cell = tableView.cellForRow(at: indexPath) as? TappableCell else { return }
        
        cell.tapped?()
    }
}

private final class CustomTaskRepeatModePickerViewViewAdapter: NSObject, UIPickerViewDataSource, UIPickerViewDelegate, RxPickerViewDataSourceType, SectionedViewDataSourceType {
    typealias Element = [[CustomStringConvertible]]
    private var items: [[CustomStringConvertible]] = []
    
    func model(at indexPath: IndexPath) throws -> Any {
        return items[indexPath.section][indexPath.row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return Theme.Controls.label(withStyle: .headline).configure {
            $0.text = items[component][row].description
            $0.textAlignment = .center
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, observedEvent: Event<Element>) {
        Binder(self) { (adapter, items) in
            adapter.items = items
            pickerView.reloadAllComponents()
            }.on(observedEvent)
    }
}
