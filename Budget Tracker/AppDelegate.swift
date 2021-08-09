//
//  AppDelegate.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{//, UNUserNotificationCenterDelegate {

    var window: UIWindow?
 //   let center = UNUserNotificationCenter.current()
 //   static var shared: AppDelegate?
    
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        let value = UserDefaults.standard.value(forKey: "lastLaunching") as? String ?? ""
        if value != today {
            UserDefaults.standard.setValue(today, forKey: "lastLaunching")
            lastSelectedDate = nil
            _categoriesHolder.removeAll()
            _debtsHolder.removeAll()
        }

        print(today, "didFinishLaunchingWithOptions")
        
      //  center.delegate = self
     /*   let window = UIApplication.shared.keyWindow ?? UIWindow()
        self.loadingIndicator.frame = window.frame
        window.addSubview(self.loadingIndicator)*/
        
      //  AppDelegate.shared = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
    
    
  /*  lazy var loadingIndicator: IndicatorView = {
        let newView = IndicatorView.instanceFromNib() as! IndicatorView
        return newView
        //return (UIApplication.shared.keyWindow ?? UIWindow()).viewWithTag(23450) as? IndicatorView ?? IndicatorView(frame: .zero)
    }()*/
    
  /*
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(#function)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(#function)
        
       // UIApplication.shared.applicationIconBadgeNumber += 1
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(#function)
        /*self.loadingIndicator.completeWithActions(buttonsTitles: ("Cancel", "View"), showCloseButton: false, leftButtonActon: { (_) in
            self.loadingIndicator.fastHide { (_) in
               // self.notificationShowed = true
            }
        }, rightButtonActon: { (_) in
            self.loadingIndicator.show { (_) in
                let load = LoadFromDB()
                load.Debts { (loadedDebts, debtsError) in
                    var debtsResult: [DebtsStruct] = []
                    for i in 0..<loadedDebts.count {
                        let name = loadedDebts[i][1]
                        let amountToPay = loadedDebts[i][2]
                        let dueDate = loadedDebts[i][3]
                        debtsResult.append(DebtsStruct(name: name, amountToPay: amountToPay, dueDate: dueDate))
                    }
                    if debtsError == "" {
                        appData.saveDebts(debtsResult)
                    }
                    var transactions:[TransactionsStruct] = []
                    let allTrans = Array(appData.getTransactions)
                    for i in 0..<allTrans.count{
                        if allTrans[i].category == notification.request.content.title {
                            transactions.append(allTrans[i])
                        }
                    }
                    DispatchQueue.main.async {
                        self.loadingIndicator.fastHide { (_) in
                           // self.showHistory(categpry: notification.request.content.title, transactions: transactions)
                        }
                    }
                }
            }

        }, title: notification.request.content.title, description: notification.request.content.body, error: false)*/
    }*/

}

