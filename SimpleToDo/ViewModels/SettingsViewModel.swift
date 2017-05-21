//
//  SettingsViewModel.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import RxDataFlow
import RxSwift
import RxDataSources

final class SettingsViewModel: ViewModelType {
	let flowController: RxDataFlowController<RootReducer>

	let isPushNotificationsAllowed: Bool
	var isPushNotificationsEnabled: Bool
	
	let title = "Settings"
	
	lazy var sections: Observable<[SettingsSection]> = {
		let pushSubtitle: String? = self.isPushNotificationsAllowed ? nil : "Notifications disabled by user"
		let pushSection = SettingsSection(header: "", items: [.pushNotificationsSwitch(title: "Receive push notifications", subtitle: pushSubtitle, image: Theme.Images.pushNotification)])
		let exitSection = SettingsSection(header: "", items: [.deleteLocalCache(title: "Delete local cache", image: Theme.Images.file),
		                                                      .exit(title: "Log off", image: Theme.Images.exit)])
		return .just([pushSection, exitSection])
	}()
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in self?.check(error: $0.error) })
	}()
	
	init(flowController: RxDataFlowController<RootReducer>) {
		self.flowController = flowController
		isPushNotificationsAllowed = flowController.currentState.state.authentication.settings?.pushNotificationsAllowed ?? false
		isPushNotificationsEnabled = flowController.currentState.state.authentication.settings?.pushNotificationsEnabled ?? false
	}
	
	func askForLogOff(sourceView: UIView) {
		flowController.dispatch(SettingsAction.showLogOffAlert(sourceView: sourceView))
	}
	
	func askForDeleteCache(sourceView: UIView) {
		flowController.dispatch(SettingsAction.showDeleteCacheAlert(sourceView: sourceView))
	}
	
	func logOff() {
		RxCompositeAction.logOffActions.forEach { flowController.dispatch($0) }
	}
	
	func done() {
		flowController.dispatch(RxCompositeAction(actions: [PushNotificationsAction.switchNotificationSubscription(subscribed: isPushNotificationsEnabled),
		                                                    UIAction.dismissSettingsController]))
	}
	
	func deleteCache() {
		flowController.dispatch(SynchronizationAction.deleteCache)
		flowController.dispatch(RxCompositeAction(actions: RxCompositeAction.refreshTokenAndSyncActions))
	}
}
