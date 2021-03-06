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
import Auth0
import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	var hasAuthenticationData: Bool {
		guard Keychain.authenticationType != nil,
			Keychain.token.count > 0,
			Keychain.refreshToken.count > 0,
			Keychain.userUuid.count > 0 else {
				return false
		}
		
		return true
	}
	
	lazy var flowController: RxDataFlowController<AppState> = {
		let httpClient = HttpClient(urlRequestCacheProvider: UrlRequestFileSystemCacheProvider(cacheDirectory: FileManager.default.documentsDirectory),
		                            requestPlugin: NetworkActivityIndicatorPlugin(application: UIApplication.shared))

		let authentication: Authentication = {
			guard self.hasAuthenticationData else { return .none }
			let authenticationInfo = AuthenticationInfo(uid: Keychain.userUuid, token: Keychain.token, expiresAt: Keychain.tokenExpirationDate, refreshToken: Keychain.refreshToken)
			return Authentication.authenticated(authenticationInfo, UserSettings())
		}()
		
		let initialState = AppState(coordinator: InitialCoordinator(window: self.window!, flowControllerInitializer: { self.flowController }),
		                            authentication: authentication,
		                            uiApplication: UIApplication.shared,
		                            authenticationService: Auth0AuthenticationService(),
		                            webService: WebSerivce(httpClient: httpClient, host: UserDefaults.standard.serverHost),
		                            repository: RealmRepository(),
		                            syncStatus: .completed)
		
		return RxDataFlowController(reducer: rootReducer, initialState: initialState)
	}()
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		window = UIWindow(frame: UIScreen.main.bounds)
		
		FileManager.default.createOrUpdateRealmsDirectory()
		
		setupPushNotifications(withLaunchOptions: launchOptions)
		
        setupBackgroundRefresh()
        scheduleBackgroundRefresh()
		
		flowController.dispatch(SynchronizationAction.updateConfiguration)
        flowController.dispatch(UIAction.showRootController)
		
		// if already authenticated prompt for push notifications
		if case Authentication.authenticated = flowController.currentState.state.authentication {
			flowController.dispatch(PushNotificationsAction.promptForPushNotifications)
		}
		
		// workaround over asynchronous flowController action dispatch
        window?.rootViewController = UIViewController()
		window?.backgroundColor = Theme.Colors.background
        window?.makeKeyAndVisible()

		return true
	}
    
    func setupBackgroundRefresh() {
        guard let id = Bundle.main.bundleIdentifier else { return }
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "\(id).backgroundRefresh",
            using: DispatchQueue.global()
        ) { [weak self] task in
            self?.handleBackgroundRefresh(task)
        }
    }
    
    private func handleBackgroundRefresh(_ task: BGTask) {
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleBackgroundRefresh() {
        do {
            guard let id = Bundle.main.bundleIdentifier else { return }
            let request = BGAppRefreshTaskRequest(identifier: "\(id).backgroundRefresh")
            request.earliestBeginDate = Date().adding(.hour, value: 1, in: .current)
            try BGTaskScheduler.shared.submit(request)
        } //catch let _ as BGTaskScheduler.Error { }
        catch { }
    }
	
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
		return Auth0.resumeAuth(url, options: options)
	}
	
    func setupPushNotifications(withLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
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
		let actions = [SystemAction.updateIconBadge] +
			RxCompositeAction.refreshTokenAndSyncActions +
			[SystemAction.updateIconBadge, SystemAction.invoke(handler: { completionHandler(.newData) })]
		let compositeAction = RxCompositeAction(actions: actions,
		                                      fallbackAction: SystemAction.invoke(handler: { completionHandler(.failed) }),
		                                      isSerial: false)
		
		flowController.dispatch(compositeAction)
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		refreshInBackground(with: completionHandler)
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		flowController.dispatch(SystemAction.updateIconBadge)
        scheduleBackgroundRefresh()
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        flowController.dispatchAfter(.milliseconds(100), action: SynchronizationAction.reload)
        flowController.dispatchAfter(.milliseconds(200), action: RxCompositeAction.synchronizationAction)
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
}
