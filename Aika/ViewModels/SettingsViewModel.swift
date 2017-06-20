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

	let isPushNotificationsAllowed: Observable<Bool>
	var isPushNotificationsEnabled: Bool
	
	let title = "Settings"
	
	lazy var sections: Observable<[SettingsSection]> = {
		return self.isPushNotificationsAllowed.flatMap { isPushNotificationsAllowed -> Observable<[SettingsSection]> in
			let pushSubtitle: String? = isPushNotificationsAllowed ? nil : "Notifications disabled by user"
			let pushSection = SettingsSection(header: "NOTIFICATIONS", items: [.pushNotificationsSwitch(title: "Receive push notifications", subtitle: pushSubtitle, image: Theme.Images.pushNotification)])
			
			let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
			let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
			let aboutSection = SettingsSection(header: "ABOUT", items: [.frameworks(title: "Frameworks", image: Theme.Images.frameworks),
			                                                            .sourceCode(title: "Source code", image: Theme.Images.sourceCode),
			                                                            .email(title: "Support", image: Theme.Images.questionMark),
			                                                            .text(title: "App version", value: "\(appVersion) (\(buildVersion))", image: nil)])
			
			let exitSection = SettingsSection(header: "ACCOUNT", items: [.deleteLocalCache(title: "Delete local cache", image: Theme.Images.deleteCache),
			                                                             .deleteAccount(title: "Delete account", image: Theme.Images.deleteAccount),
			                                                             .exit(title: "Log off", image: Theme.Images.exit)])
			return .just([pushSection, exitSection, aboutSection])
		}
	}()
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in self?.check(error: $0.error) })
	}()
	
	init(flowController: RxDataFlowController<RootReducer>) {
		self.flowController = flowController
		isPushNotificationsAllowed = flowController.currentState.state.authentication.settings?.pushNotificationsAllowed ?? .just(false)
		isPushNotificationsEnabled = flowController.currentState.state.authentication.settings?.pushNotificationsEnabled ?? false
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
	
	func deleteUser() {
		flowController.dispatch(UIAction.showSpinner)
		flowController.dispatch(RxCompositeAction.deleteUserAction)
		flowController.dispatch(UIAction.hideSpinner)
	}
	
	func showFramwrorks() {
		flowController.dispatch(SettingsAction.showFrameworksController)
	}
}
