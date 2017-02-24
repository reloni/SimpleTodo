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
//import GoogleSignIn
//import Firebase

//let httpClient = HttpClient(urlRequestCacheProvider: UrlRequestFileSystemCacheProvider(cacheDirectory: FileManager.default.documentsDirectory))
//let applicationStore = RxDataFlowController(reducer: AppReducer(),
//                                            initialState: AppState(coordinator: RootApplicationCoordinator(),
//                                                                   rootController: MainController(),
//                                                                   logInInfo: LogInInfo(email: "john@domain.com", password: "ololo"),
//                                                                   httpClient: HttpClient(urlRequestCacheProvider: UrlRequestFileSystemCacheProvider(cacheDirectory: FileManager.default.documentsDirectory), requestPlugin: NetworkActivityIndicatorPlugin(application: UIApplication.shared)),
//                                                                   tasks: []))

var applicationStore: RxDataFlowController<AppState>!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		
		FIRApp.configure()
		
		applicationStore = RxDataFlowController(reducer: AppReducer(),
		                                        initialState: AppState(coordinator: RootApplicationCoordinator(window: window!),
		                                                                   rootController: MainController(),
		                                                                   logInInfo: LogInInfo(email: "john@domain.com", password: "ololo"),
		                                                                   httpClient: HttpClient(urlRequestCacheProvider: UrlRequestFileSystemCacheProvider(cacheDirectory: FileManager.default.documentsDirectory), requestPlugin: NetworkActivityIndicatorPlugin(application: UIApplication.shared)),
		                                                                   tasks: []))
		
		applicationStore.dispatch(AppAction.showRootController)
		
		//applicationStore.currentState.state.rootController.viewControllers.append(SignInController())
		//window?.rootViewController = applicationStore.currentState.state.rootController
		//window?.makeKeyAndVisible()
		return true
	}
	
//	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//		return GIDSignIn.sharedInstance().handle(url,
//		                                         sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
//		                                         annotation: [:])
//	}

	func applicationWillResignActive(_ application: UIApplication) {
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

/*
extension AppDelegate : GIDSignInDelegate {
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
		print("didSignInFor")
  // ...
  if let error = error {
		// ...
		return
  }
		
  guard let authentication = user.authentication else { return }
  let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                    accessToken: authentication.accessToken)
	
  FIRAuth.auth()?.signIn(with: credential) { (user, error) in
		print("fir auth")
		
		if let error = error {
			// ...
			return
		}
		}
	}
	
	func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!, withError error: NSError!) {
		print("didDisconnectWithUser")
		// Perform any operations when the user disconnects from app here.
		// ...
	}
}
*/
