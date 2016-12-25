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
	
	var work: (RxStateType) -> Observable<RxActionResultType> {
		switch self {
		case .reloadToDoEntries(let entries): return reload(entries: entries)
		case .loadToDoEntries(let client, let request): return reload(client: client, request: request)
		case .deleteToDoEntry(let id): return delete(entryId: id)
		case .addToDoEntry(let entry): return add(entry: entry)
		}
	}
}

func reload(entries: [ToDoEntry]) -> (RxStateType) -> Observable<RxActionResultType> {
	return { _ in Observable.just(RxDefaultActionResult(entries)) }
}

func reload(client: HttpClientType, request: URLRequest) -> (RxStateType) -> Observable<RxActionResultType> {
	return { _ in
		return client.requestData(request).flatMap { result -> Observable<RxActionResultType> in
			sleep(2)
			let entries: [ToDoEntry] = try unbox(data: result)
			return Observable.just(RxDefaultActionResult(entries))
		}
	}
}

func delete(entryId id: Int) -> (RxStateType) -> Observable<RxActionResultType> {
	return { _ in
		Observable.just(RxDefaultActionResult(id))
	}
}

func add(entry: ToDoEntry) -> (RxStateType) -> Observable<RxActionResultType> {
	return { _ in
		Observable.just(RxDefaultActionResult(entry))
	}
}
