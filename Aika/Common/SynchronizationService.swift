//
//  SynchronizationService.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 09.05.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

protocol SynchronizationServiceType {
	var webService: WebServiceType { get }
	
	func synchronize(authenticationInfo: AuthenticationInfo, repository: RepositoryType) -> Observable<Void>
	func deleteUser(authenticationInfo: AuthenticationInfo) -> Observable<Void>
	func logOut(authenticationInfo: AuthenticationInfo) -> Observable<Void>
}

final class SynchronizationService: SynchronizationServiceType {
	let webService: WebServiceType

	init(webService: WebServiceType) {
		self.webService = webService
	}

	func deleteUser(authenticationInfo: AuthenticationInfo) -> Observable<Void> {
		return webService.deleteUser(tokenHeader: authenticationInfo.tokenHeader)
	}

	func logOut(authenticationInfo: AuthenticationInfo) -> Observable<Void> {
		return webService.logOut(refreshToken: authenticationInfo.refreshToken, tokenHeader: authenticationInfo.tokenHeader)
	}
	
	func synchronize(authenticationInfo: AuthenticationInfo, repository: RepositoryType) -> Observable<Void> {
		var toCreate = [Task]()
		var toUpdate = [Task]()
		var toDelete = [UniqueIdentifier]()
		
		repository.modifiedTasks().forEach {
			switch $0.synchronizationStatus {
			case .created: toCreate.append($0.toStruct())
			case .modified: toUpdate.append($0.toStruct())
			case .deleted: toDelete.append(UniqueIdentifier(identifierString: $0.uuid)!)
			default: break
			}
		}
		
		return webService.update(with: BatchUpdate(toCreate: toCreate, toUpdate: toUpdate, toDelete: toDelete), tokenHeader: authenticationInfo.tokenHeader)
			.flatMapLatest { result -> Observable<Void> in
				try? repository.removeAllTasks()
				_ = try? repository.import(tasks: result)
				return .empty()
			}
	}
}
