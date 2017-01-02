//
//  State.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 18.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import Foundation
import RxState
import RxSwift
import RxHttpClient
import Unbox
import UIKit
import Wrap
import UIKit

struct AppState : RxStateType {
	let rootController: MainController
	let logInInfo: LogInInfo?
	let httpClient: HttpClientType
	let toDoEntries: [ToDoEntry]
}

extension AppState {
	func new(toDoEntries: [ToDoEntry]) -> AppState {
		return AppState(rootController: rootController, logInInfo: logInInfo, httpClient: httpClient, toDoEntries: toDoEntries)
	}
}

enum AppAction : RxActionType {
	case reloadToDoEntries([ToDoEntry])
	case loadToDoEntries
	case addToDoEntry(ToDoEntry)
	case showEditEntryController(ToDoEntry?)
	case dismisEditEntryController
	case deleteToDoEntry(Int)
	case showAllert(in: UIViewController, with: Error)
	case updateEntry(ToDoEntry)
	
	var work: RxActionWork {
		switch self {
		case .reloadToDoEntries: return reloadEntriesActionWork(fromRemote: false)
		case .loadToDoEntries: return reloadEntriesActionWork(fromRemote: true)
		case .deleteToDoEntry(let id): return deleteEntryActionWork(entryId: id)
		case .addToDoEntry(let entry): return addEntryActionWork(entry: entry)
		case .showEditEntryController(let entry): return showEditEntryControllerActionWork(entry)
		case .dismisEditEntryController: return dismisEditEntryControllerActionWork()
		case .updateEntry(let entry): return updateEntryActionWork(entry)
		case .showAllert(let controller, let error): return showAlertActionWork(in: controller, with: error)
		}
	}
}
