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
	
	var hasAuthenticationData: Bool {
		guard Keychain.userEmail.characters.count > 0,
			Keychain.userPassword.characters.count > 0,
			Keychain.token.characters.count > 0,
			Keychain.refreshToken.characters.count > 0,
			Keychain.userUuid.characters.count > 0 else {
				return false
		}
		
		return true
	}
	
	lazy var flowController: RxDataFlowController<RootReducer> = {
		let httpClient = HttpClient(urlRequestCacheProvider: UrlRequestFileSystemCacheProvider(cacheDirectory: FileManager.default.documentsDirectory),
		                            requestPlugin: NetworkActivityIndicatorPlugin(application: UIApplication.shared))
		
		let authentication: Authentication = {
			guard self.hasAuthenticationData else { return .none }
			let authenticationInfo = AuthenticationInfo(uid: Keychain.userUuid, token: Keychain.token, expiresAt: nil, refreshToken: Keychain.refreshToken)
			return Authentication.authenticated(authenticationInfo, UserSettings())
		}()
		
		let initialState = AppState(coordinator: InitialCoordinator(window: self.window!, flowControllerInitializer: { self.flowController }),
		                            authentication: authentication,
		                            uiApplication: UIApplication.shared,
		                            authenticationService: Auth0AuthenticationService(),
		                            syncService: SynchronizationService(webService: WebSerivce(httpClient: httpClient), repository: RealmRepository()),
		                            syncStatus: .completed)
		
		return RxDataFlowController(reducer: RootReducer(), initialState: initialState, maxHistoryItems: 1)
	}()
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		
		FileManager.default.createOrUpdateRealmsDirectory()
		
		setupPushNotifications(withLaunchOptions: launchOptions)
		
		UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
		
		flowController.dispatch(SynchronizationAction.updateConfiguration)
		flowController.dispatch(UIAction.showRootController)

		return true
	}
	
	func setupPushNotifications(withLaunchOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
		let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,
		                             kOSSettingsKeyInAppLaunchURL: true]
		
		OneSignal.initWithLaunchOptions(launchOptions,
		                                appId: "ffe9789a-e9bc-4789-9cbb-4552664ba3fe",
		                                handleNotificationReceived: nil,
		                                handleNotificationAction: nil,
		                                settings: onesignalInitSettings)
		
		OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
	}

	func refreshInBackground(with completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		// compose refreshing action
		let actions = RxCompositeAction.refreshTokenAndSyncActions +
			[SystemAction.updateIconBadge, SystemAction.invoke(handler: { print("completed"); completionHandler(.newData) })]
		let compositeAction = RxCompositeAction(actions: actions,
		                                      fallbackAction: SystemAction.invoke(handler: { print("failed"); completionHandler(.failed) }),
		                                      isSerial: false)
		
		flowController.dispatch(compositeAction)
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		refreshInBackground(with: completionHandler)
	}
	
	func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		refreshInBackground(with: completionHandler)
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		flowController.dispatch(SystemAction.updateIconBadge)
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		flowController.dispatch(RxCompositeAction.synchronizationAction)
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
}
