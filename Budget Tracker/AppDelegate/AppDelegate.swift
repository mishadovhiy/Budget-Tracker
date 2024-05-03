//
//  AppDelegate.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData
#if os(iOS)
import WatchConnectivity
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    static var properties:AppProperties?
    static var shared:AppDelegate {
        return UIApplication.shared.delegate as? AppDelegate ?? .init()
    }
    var navigationVC:UINavigationController? {
        return UIApplication.shared.sceneKeyWindow?.rootViewController as? UINavigationController
    }
    
    var canPerformAction:Bool {
        if let properties = AppDelegate.properties {
            return !(!properties.ai.canHideAlert || properties.passcodeLock.presenting)
        } else {
            return false
        }
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.properties = .init()
        return true
    }
    
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let type = ShortCodeItem.init(rawValue: shortcutItem.type) else {
            print("unrecognized item pressed")
            return
        }
        var vc:UIViewController?
        switch type {
        case .addTransaction:
            vc = TransactionNav.configure(TransitionVC.configure())
        case .addReminder:
            RemindersVC.showPaymentReminders()
            return
        case .monthlyLimits:
            vc = NavigationController(rootViewController: CategoriesVC.configure())
        }
        if let vcc = vc {
            vc = nil
            AppDelegate.properties?.appData.present(vc: vcc)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        AppDelegate.properties?.receinActive()
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print(#function)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppDelegate.properties?.becomeActive()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print(#function)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print(#function)
        
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        performBackgroundFetch {
            completionHandler($0 ? .failed : .newData)
        }
    }
    
    func performBackgroundFetch(completion:((_ error:Bool)->())? = nil) {
        DispatchQueue(label: "api", qos: .userInitiated).async {
            LoadFromDB().newTransactions(completion: { _,error  in
                DispatchQueue.main.async {
                    completion?(error != .none)
                }
            })
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "LocalDataBase")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 */
                //    fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                // fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate:WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print(session, " jtyhrtgf sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print(session, " thrgerfewdrgtr sessionDidDeactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("message received from watch: ", message)
        let delegate = AppDelegate.properties
        DispatchQueue(label: "db", qos: .userInitiated).async {
            if let username = delegate?.db.username, username != "" {
                let username = username
                DispatchQueue.main.async {
                    WCSession.default.sendMessage(["username":username], replyHandler: nil)
                }
            } else {
                DispatchQueue.main.async {
                    HomeVC.shared?.navigationController?.pushViewController(LoginViewController.configure(), animated: true)
                }
            }
        }
        
    }
    
    func sendUsernametoWatch() {
        
    }
    
}

protocol AppDelegateProtocol {
    func resighnActive()
}
#else
class AppDelegate {
    static var shared:AppDelegate?
    static var properties:AppProperties?
    init() {
        AppDelegate.shared = self
        AppDelegate.properties = .init()
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocalDataBase")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let _ = error as NSError? {
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                // fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

#endif

