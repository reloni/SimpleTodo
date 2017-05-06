//
//  AppDelegate.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 01.12.16.
//  Copyright © 2016 Anton Efimenko. All rights reserved.
//

import UIKit
import RxHttpClient
import RxDataFlow
import RxSwift
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	lazy var flowController: RxDataFlowController<AppState> = {
		let httpClient = HttpClient(urlRequestCacheProvider: UrlRequestFileSystemCacheProvider(cacheDirectory: FileManager.default.documentsDirectory),
		                            requestPlugin: NetworkActivityIndicatorPlugin(application: UIApplication.shared))
		let initialState = AppState(coordinator: InitialCoordinator(window: self.window!),
		                            authentication: .none,
		                            webService: WebSerivce(httpClient: httpClient),
		                            tasks: [],
		                            uiApplication: UIApplication.shared,
		                            authenticationService: Auth0AuthenticationService())
		
		return RxDataFlowController(reducer: RootReducer(), initialState: initialState, maxHistoryItems: 1)
	}()
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		
		setupPushNotifications(withLaunchOptions: launchOptions)
		
		UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
		
		flowController.dispatch(UIAction.showRootController)

		return true
	}
	
	func notificationOpened(result: OSNotificationOpenedResult?) {
		// This block gets called when the user reacts to a notification received
		let payload: OSNotificationPayload = result!.notification.payload
		
		let fullMessage = payload.body ?? ""
		print("Message = \(fullMessage)")
		
		//			if payload.additionalData != nil {
		//				if payload.title != nil {
		//					let messageTitle = payload.title
		//					print("Message Title = \(messageTitle!)")
		//				}
		//
		//				let additionalData = payload.additionalData
		//				if additionalData?["actionSelected"] != nil {
		//					fullMessage = fullMessage! + "\nPressed ButtonID: \(additionalData!["actionSelected"])"
		//				}
		//			}
	}
	
	func notificationReceived(notification: OSNotification?) {
		print("Received Notification: \(notification!.payload.notificationID)")
		flowController.dispatch(UIAction.updateIconBadge)
	}
	
	func setupPushNotifications(withLaunchOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
		let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,
		                             kOSSettingsKeyInAppLaunchURL: true]
		
		OneSignal.initWithLaunchOptions(launchOptions,
		                                appId: "ffe9789a-e9bc-4789-9cbb-4552664ba3fe",
		                                handleNotificationReceived: notificationReceived,
		                                handleNotificationAction: notificationOpened,
		                                settings: onesignalInitSettings)
		
		OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
	}
	
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
	}
	
	func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		flowController.dispatch(UIAction.updateIconBadge)
		completionHandler(.newData)
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		flowController.dispatch(UIAction.updateIconBadge)
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
}
