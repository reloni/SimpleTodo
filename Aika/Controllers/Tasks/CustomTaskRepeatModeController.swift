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
            configureCell: { [unowned self] ds, tv, ip, item in
                switch item {
                case .placeholder:
                    let cell = PlaceholderCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
                    cell.contentView.backgroundColor = Theme.Colors.secondaryBackground
                    cell.selectionStyle = .none
                    return cell
                case .patternTypePicker: return self.patternTypePickerCell()
                case .repeatEveryPicker: return self.repeatEveryPickerCell()
                case .patternType: return self.tappableCell(for: item, tapped: { [weak self] in self?.patternTypeSelectionToggledSubject.onNext(()) })
                case .repeatEvery: return self.tappableCell(for: item, tapped: { [weak self] in self?.repeatEverySelectionToggledSubject.onNext(()) })
                case .weekday(let value):
                    return self.weekdayCell(name: value.name,
                                            isSelected: value.isSelected,
                                            tapped: { [weak self] in self?.weekdaySelectedSubject.onNext(value.value) })
                case .monthDays(let value):
                    return CalendarDateCell(style: .default, reuseIdentifier: nil)
                }
            },
            canEditRowAtIndexPath: { _, _ in return false })
	}()
    
    let patternTypeSelectionToggledSubject = PublishSubject<Void>()
    let repeatEverySelectionToggledSubject = PublishSubject<Void>()
    let weekdaySelectedSubject = PublishSubject<TaskScheduler.DayOfWeek>()
    let saveSubject = PublishSubject<Void>()
	
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
		view.backgroundColor = Theme.Colors.secondaryBackground
		
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
            saveSubject.onNext(())
        }
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
        
        weekdaySelectedSubject
            .bind(to: viewModel.inputs.weekdaySelected)
            .disposed(by: bag)
        
        saveSubject.bind(to: viewModel.inputs.save).disposed(by: bag)
		
        tableView.rx.setDelegate(tableViewDelegate).disposed(by: bag)
	}
    
    func tappableCell(for item: CustomTaskRepeatModeSectionItem, tapped: @escaping () -> Void) -> TappableCell {
        let cell = TappableCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
        cell.textLabel?.text = item.mainText
        cell.detailTextLabel?.text = item.detailText
        cell.selectionStyle = .none
        cell.tapped = tapped
        return cell
    }
    
    func weekdayCell(name: String, isSelected: Bool, tapped: @escaping () -> Void) -> TappableCell {
        let cell = TappableCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: nil)
        cell.textLabel?.text = name
        if isSelected {
            cell.accessoryView = UIImageView(image: Theme.Images.checked.resize(toWidth: 22))
        } else {
            cell.accessoryView = UIImageView(image: Theme.Images.empty.resize(toWidth: 22))
        }
        cell.preservesSuperviewLayoutMargins = false
        
        cell.selectionStyle = .none
        cell.tapped = tapped
        return cell
    }

    
    func repeatEveryPickerCell() -> PickerCell {
        let cell = PickerCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        
        viewModel.outputs.repeatEveryItems
            .bind(to: cell.picker.rx.items(adapter: CustomTaskRepeatModePickerViewViewAdapter()))
            .disposed(by: cell.bag)
        
        cell.picker.rx.itemSelected
            .map { $0.row + 1 }
            .bind(to: viewModel.inputs.repeatEvery)
            .disposed(by: cell.bag)
        
        viewModel.state.take(1).map { $0.repeatEvery }.subscribe(onNext: { [weak cell] repeatEvery in
            cell?.picker.selectRow(repeatEvery - 1, inComponent: 0, animated: true)
        }).disposed(by: cell.bag)
        
        return cell
    }
    
    func patternTypePickerCell() -> PickerCell {
        let cell = PickerCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
        
        viewModel.outputs.patternTypetems
            .bind(to: cell.picker.rx.items(adapter: CustomTaskRepeatModePickerViewViewAdapter()))
            .disposed(by: cell.bag)
        
        cell.picker.rx
            .modelSelected(CustomRepeatPatternType.self)
            .map { $0.first! }
            .bind(to: viewModel.inputs.patternType)
            .disposed(by: cell.bag)
        
        viewModel.state.take(1).map { $0.pattern }.withLatestFrom(viewModel.outputs.patternTypetems) { ($0, $1) }.subscribe(onNext: { [weak cell] data in
            if let index = data.1[0].enumerated().first(where: { $0.element.description == data.0.description })?.offset {
                cell?.picker.selectRow(index, inComponent: 0, animated: true)
            }
        }).disposed(by: cell.bag)
        
        return cell
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
