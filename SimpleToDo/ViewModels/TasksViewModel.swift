//
//  TasksViewModel.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 19.02.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataSources
import RxDataFlow
import RxSwift

final class TasksViewModel {
	let dataSource = RxTableViewSectionedAnimatedDataSource<TaskSection>()
	
	let flowController: RxDataFlowController<AppState>
	
	let tableViewDelegate = TasksViewModelTableViewDelegate()
	
	let title = "Tasks"
	
	lazy var taskSections: Observable<[TaskSection]> = {
		return self.flowController.state.filter {
			switch $0.setBy {
			case EditTaskAction.addTask: fallthrough
			case TaskListAction.deleteTask: fallthrough
			case EditTaskAction.updateTask: fallthrough
			case TaskListAction.completeTask: fallthrough
			case TaskListAction.loadTasks: return true
			default: return false
			}
			}
			.flatMap { newState ->  Observable<[TaskSection]> in
				return Observable.just([TaskSection(header: "Tasks", items: newState.state.tasks)])
		}
	}()
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in
			guard let object = self else { return }
			object.flowController.dispatch(GeneralAction.error($0.error))
		})
	}()
	
	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
		configureDataSource()
	}
	
	func configureDataSource() {
		dataSource.configureCell = { ds, tv, ip, item in
			let cell = tv.dequeueReusableCell(withIdentifier: "TaskCell", for: ip) as! TaskCell
			cell.preservesSuperviewLayoutMargins = false
			cell.separatorInset = .zero
			cell.layoutEdgeInsets = .zero
			cell.selectionStyle = .none
			cell.isExpanded = false
			cell.taskDescription.text = "\(item.description)"
			cell.targetDate.text = item.targetDate?.date.longDate
			cell.updateConstraints()
			
			cell.completeTapped = { [weak self] in
				guard let object = self else { return }
				guard let row = tv.indexPath(for: cell)?.row else { return }
				object.flowController.dispatch(TaskListAction.completeTask(row))
			}
			
			cell.editTapped = { [weak self] in
				guard let object = self else { return }
				guard let row = tv.indexPath(for: cell)?.row else { return }
				object.flowController.dispatch(TaskListAction.showEditTaskController(object.flowController.currentState.state.tasks[row]))
			}
			
			cell.deleteTapped = { [weak self] in
				guard let object = self else { return }
				guard let row = tv.indexPath(for: cell)?.row else { return }
				object.flowController.dispatch(TaskListAction.deleteTask(row))
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
		flowController.dispatch(TaskListAction.loadTasks)
	}
	
	func newTask() {
		flowController.dispatch(TaskListAction.showEditTaskController(nil))
	}
	
	func logOff() {
		flowController.dispatch(GeneralAction.logOff)
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
