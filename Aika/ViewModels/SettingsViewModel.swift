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
	let flowController: RxDataFlowController<AppState>

	let isPushNotificationsAllowed: Observable<Bool>
	var isPushNotificationsEnabled: Bool
    
    var taskIncludeTime: Bool
	
	let title = "Settings"
	
	lazy var sections: Observable<[SettingsSection]> = {
		return self.flowController.state.filter {
			switch $0.setBy {
			case SettingsAction.reloadTable: fallthrough
			case SystemAction.setBadgeStyle: return true
			default: return false
			}
			}
			.flatMap { newState ->  Observable<[SettingsSection]> in
				return SettingsViewModel.buidSections(for: newState.state)
			}
	}()
	
	lazy var errors: Observable<(state: AppState, action: RxActionType, error: Error)> = {
		return self.flowController.errors.do(onNext: { [weak self] in self?.check(error: $0.error) })
	}()
	
	init(flowController: RxDataFlowController<AppState>) {
		self.flowController = flowController

		isPushNotificationsAllowed = flowController.currentState.state.authentication.settings?.pushNotificationsAllowed ?? .just(false)
		isPushNotificationsEnabled = flowController.currentState.state.authentication.settings?.pushNotificationsEnabled ?? false
        taskIncludeTime = flowController.currentState.state.taskIncludeTime
	}
	
	static func buidSections(for state: AppState) -> Observable<[SettingsSection]> {
		return (state.authentication.settings?.pushNotificationsAllowed ?? .just(false)).flatMap { isPushNotificationsAllowed -> Observable<[SettingsSection]> in
			let badgeDescription = state.badgeStyle.description
			let pushSubtitle: String? = isPushNotificationsAllowed ? nil : "Notifications disabled by user"
			
			let pushSection = SettingsSection(header: "NOTIFICATIONS",
			                                  items: [.pushNotificationsSwitch(title: "Receive push notifications", subtitle: pushSubtitle, image: Theme.Images.pushNotification),
			                                          .iconBadgeStyle(title: "Badge", value: badgeDescription, image: Theme.Images.badge),
                                                      .includeTimeSwitch(title: "Include time", subtitle: "Include Time default value for a new task", image: Theme.Images.clock)
                                              ])
			
			let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
			let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
			let aboutSection = SettingsSection(header: "ABOUT", items: [.frameworks(title: "Frameworks", image: Theme.Images.frameworks),
			                                                            .sourceCode(title: "Source code", image: Theme.Images.sourceCode),
			                                                            .email(title: "Support", image: Theme.Images.questionMark),
			                                                            .text(title: "App version", value: "\(appVersion) (\(buildVersion))", image: nil)])
			
			let exitSection = SettingsSection(header: "ACCOUNT", items: [.deleteAccount(title: "Delete account", image: Theme.Images.deleteAccount),
			                                                             .deleteLocalCache(title: "Delete local cache", image: Theme.Images.deleteCache),
			                                                             .exit(title: "Log off", image: Theme.Images.exit)])
			return .just([pushSection, exitSection, aboutSection])
		}
	}
	
	func reloadSections() {
		flowController.dispatch(SettingsAction.reloadTable)
	}
	
	func updateBadgeStyle(_ style: IconBadgeStyle) {
		flowController.dispatch(SystemAction.setBadgeStyle(style))
		flowController.dispatch(AnalyticalAction.setBadgeStyle(style))
	}
	
	func logOff() {
		RxCompositeAction.logOffActions.forEach { flowController.dispatch($0) }
	}
	
	func done() {
        let actions: [RxActionType?] = [PushNotificationsAction.switchNotificationSubscription(subscribed: isPushNotificationsEnabled),
                                        SystemAction.setIncludeTime(taskIncludeTime),
                                        UIAction.dismissSettingsController,
                                        pushNotificationSwitchAnalyticalAction()]
        flowController.dispatch(RxCompositeAction(actions: actions.compactMap { $0 }))
	}
	
	func pushNotificationSwitchAnalyticalAction() -> AnalyticalAction? {
		guard let current = flowController.currentState.state.authentication.settings?.pushNotificationsEnabled else {
			return nil
		}
		
		guard current != isPushNotificationsEnabled else { return nil }
		
		if isPushNotificationsEnabled {
			return AnalyticalAction.enablePushNotifications
		} else {
			return AnalyticalAction.disablePushNotifications
		}
	}
	
	func deleteCache() {
		flowController.dispatch(SynchronizationAction.deleteCache)
		flowController.dispatch(RxCompositeAction(actions: RxCompositeAction.refreshTokenAndSyncActions))
		flowController.dispatch(AnalyticalAction.deleteCache)
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
