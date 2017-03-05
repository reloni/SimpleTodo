//
//  TasksViewModel.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 19.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import RxDataSources
import RxDataFlow
import RxSwift

final class TasksViewModel {
	let dataSource = RxTableViewSectionedAnimatedDataSource<TaskSection>()
	
	let appStore: RxDataFlowController<AppState>
	let viewController: UIViewController
	
	let tableViewDelegate = TasksViewModelTableViewDelegate()
	
	lazy var taskSections: Observable<[TaskSection]> = {
		return self.appStore.state.filter {
			switch $0.setBy {
//			case AppAction.addTask: fallthrough
//			case AppAction.deleteTask: fallthrough
//			case AppAction.loadTasks: fallthrough
//			case AppAction.updateTask: fallthrough
//			case AppAction.completeTask: fallthrough
			case TaskListAction.loadTasks: return true
			default: return false
			}
			}
			.flatMap { newState ->  Observable<[TaskSection]> in
				return Observable.just([TaskSection(header: "Tasks", items: newState.state.tasks)])
		}
	}()
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.appStore.errors.do(onNext: { [weak self] in
			guard let object = self else { return }
			object.appStore.dispatch(AppAction.showAllert(in: object.viewController, with: $0.error))
		})
	}()
	
	init(viewController: UIViewController, applicationStore: RxDataFlowController<AppState>) {
		self.viewController = viewController
		appStore = applicationStore
		configureDataSource()
	}
	
	func configureDataSource() {
		dataSource.configureCell = { ds, tv, ip, item in
			let cell = tv.dequeueReusableCell(withIdentifier: "TaskCell", for: ip) as! TaskCell
			cell.separatorInset = .zero
			cell.layoutEdgeInsets = .zero
			cell.selectionStyle = .none
			cell.isExpanded = false
			cell.taskDescription.text = "Item \(item.description) - \(item.completed)"
			
			cell.completeTapped = { [weak self] in
				guard let object = self else { return }
				guard let row = tv.indexPath(for: cell)?.row else { return }
				object.appStore.dispatch(AppAction.completeTask(row))
			}
			
			cell.editTapped = { [weak self] in
				guard let object = self else { return }
				guard let row = tv.indexPath(for: cell)?.row else { return }
				object.appStore.dispatch(AppAction.showEditTaskController(object.appStore.currentState.state.tasks[row]))
			}
			
			cell.deleteTapped = { [weak self] in
				guard let object = self else { return }
				guard let row = tv.indexPath(for: cell)?.row else { return }
				object.appStore.dispatch(AppAction.deleteTask(row))
			}
			return cell
		}
		
		dataSource.canEditRowAtIndexPath = { _ in
			return true
		}
		
		dataSource.canMoveRowAtIndexPath = { _ in
			return true
		}
	}
	
	func loadTasks() {
		appStore.dispatch(TaskListAction.loadTasks)
	}
	
	func newTask() {
		appStore.dispatch(TaskListAction.showEditTaskController(nil))
	}
}

final class TasksViewModelTableViewDelegate : NSObject, UITableViewDelegate {
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return UITableViewCellEditingStyle.delete
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return }
		
		cell.isExpanded = !cell.isExpanded
		animateCellExpansion(forIndexPath: indexPath, tableView: tableView)
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? TaskCell else { return }
		
		cell.isExpanded = false
		animateCellExpansion(forIndexPath: nil, tableView: tableView)
	}
	
	func animateCellExpansion(forIndexPath indexPath: IndexPath?, tableView: UITableView) {
		tableView.beginUpdates()
		tableView.endUpdates()
		
		if let indexPath = indexPath, tableView.numberOfRows(inSection: 0) == indexPath.row + 1 {
			tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
		}
	}
}
