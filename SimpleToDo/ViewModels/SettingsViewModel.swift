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

final class SettingsViewModel {
	let flowController: RxDataFlowController<AppState>

	let isPushNotificationsAllowed: Bool
	var isPushNotificationsEnabled: Bool
	
	let title = "Settings"
	
	let sections = Observable<[SettingsSection]>.just([SettingsSection(header: "", items: [.pushNotificationsSwitch(title: "Receive push notifications", image: Theme.Images.pushNotification)]),
	                                                   SettingsSection(header: "", items: [.info(title: "About", image: Theme.Images.info),
	                                                                                             .deleteAccount(title: "Delete account", image: Theme.Images.deleteAccount),
	                                                                                             .exit(title: "Log off", image: Theme.Images.exit)])])
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in
			guard let object = self else { return }
			if case AuthenticationError.notAuthorized = $0.error {
				RxCompositeAction.logOffActions.forEach { object.flowController.dispatch($0) }
				object.flowController.dispatch(UIAction.showErrorMessage($0.error))
			} else {
				object.flowController.dispatch(UIAction.showSnackView(error: $0.error, hideAfter: 4))
			}
		})
	}()
	
	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController
		isPushNotificationsAllowed = flowController.currentState.state.authentication.settings?.pushNotificationsAllowed ?? false
		isPushNotificationsEnabled = flowController.currentState.state.authentication.settings?.pushNotificationsEnabled ?? false
	}
	
	func askForLogOff(sourceView: UIView) {
		flowController.dispatch(SettingsAction.showLogOffAlert(sourceView: sourceView))
	}
	
	func logOff() {
		RxCompositeAction.logOffActions.forEach { flowController.dispatch($0) }
	}
	
	func done() {
		flowController.dispatch(RxCompositeAction(actions: [PushNotificationsAction.switchNotificationSubscription(subscribed: isPushNotificationsEnabled),
		                                                    UIAction.dismissSettingsController]))
	}
}
