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

struct AppState : RxStateType {
	let toDoEntries: [ToDoEntry]
}

enum AppAction : RxActionType {
	case reloadToDoEntries([ToDoEntry])
	case loadToDoEntries(HttpClientType, URLRequest)
	case addToDoEntry(ToDoEntry)
	case deleteToDoEntry(Int)
	
	var work: () -> Observable<RxActionResultType> {
		switch self {
		case .reloadToDoEntries(let entries): return reload(entries: entries)
		case .loadToDoEntries(let client, let request): return reload(client: client, request: request)
		case .deleteToDoEntry(let id): return delete(entryId: id)
		case .addToDoEntry(let entry): return add(entry: entry)
		}
	}
}

func reload(entries: [ToDoEntry]) -> () -> Observable<RxActionResultType> {
	return { Observable.just(DefaultActionResult(entries)) }
}

func reload(client: HttpClientType, request: URLRequest) -> () -> Observable<RxActionResultType> {
	return {
		return client.requestData(request).flatMap { result -> Observable<RxActionResultType> in
			sleep(2)
			let entries: [ToDoEntry] = try unbox(data: result)
			return Observable.just(DefaultActionResult(entries))
		}
	}
}

func delete(entryId id: Int) -> () -> Observable<RxActionResultType> {
	return {
		Observable.just(DefaultActionResult(id))
	}
}

func add(entry: ToDoEntry) -> () -> Observable<RxActionResultType> {
	return {
		Observable.just(DefaultActionResult(entry))
	}
}
