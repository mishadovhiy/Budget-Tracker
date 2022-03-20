//
//  AppDelegate.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    static let shared = AppDelegate()
    
    
    let center = UNUserNotificationCenter.current()
    
    lazy var newMessage: MessageView = {
        return MessageView.instanceFromNib() as! MessageView
    }()
    lazy var ai: IndicatorView = {
        let newView = IndicatorView.instanceFromNib() as! IndicatorView
        return newView
    }()
    
    lazy var passcodeLock: PascodeLockView = {
        let newView = PascodeLockView.instanceFromNib() as! PascodeLockView
        return newView
    }()
    

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window?.tintColor = AppData.colorNamed(AppData.linkColor)
        center.delegate = self
        window?.backgroundColor = K.Colors.primaryBacground
        let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        let value = UserDefaults.standard.value(forKey: "lastLaunching") as? String ?? ""
        if value != today {
            UserDefaults.standard.setValue(today, forKey: "lastLaunching")
            lastSelectedDate = nil
            _categoriesHolder.removeAll()
        }
        
        
        
        print(today, "didFinishLaunchingWithOptions")
        center.getDeliveredNotifications { notifications in
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = notifications.count + appData.deliveredNotificationIDs.count
            }
        }
        
        
        
        let localization = UserDefaults.standard.value(forKey: "Localization") as? String
        let devicaLoc = NSLocale.current.languageCode ?? "-"
        print(devicaLoc, "devicaLocdevicaLocdevicaLocdevicaLoc")
        AppLocalization.launchedLocalization = localization ?? devicaLoc
        
        
        return true
    }
    
    
    
    var delegate:AppDelegateProtocol?
    private var backgroundEnterDate:Date?
    
    func applicationWillResignActive(_ application: UIApplication) {
        if UserSettings.Security.password != "" {
            backgroundEnterDate = Date();
            passcodeLock.present()
        }
    }
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        if appData.devMode {
            let button = IndicatorView.button(title: "ok", style: .error, close: true) { _ in
                
            }
            DispatchQueue.main.async {
                self.ai.completeWithActions(buttons: (button, nil), title:"Memory warning!")
            }
        }
        
        print(#function)
    }
    var becameActive = false
    func applicationDidBecomeActive(_ application: UIApplication) {
        print(#function)
        if !becameActive {
            becameActive = true
        } else {
            needDownloadOnMainAppeare = true
        }
        if UserSettings.Security.password != "" {
            guard let logoutDate = backgroundEnterDate else{
                passcodeLock.present()
                passcodeLock.passcodeLock()
                return;
            }
            let now = Date()
            let ti = now.timeIntervalSince(logoutDate)
            let timeout = Double(UserSettings.Security.timeOut) ?? 15
            if ti > timeout {
                passcodeLock.passcodeLock()
            } else {
                if !passcodeLock.passwordNotEntered {
                    passcodeLock.hide()
                }
                
            }
        }
        
    }
    func applicationWillTerminate(_ application: UIApplication) {
        print(#function)
    }
    
    func removeNotification(id:String) {
        center.removeDeliveredNotifications(withIdentifiers: [id])
        let deliveredHolder = appData.deliveredNotificationIDs
        var newNotif:[String] = []
        for i in 0..<deliveredHolder.count {
            if deliveredHolder[i] != id {
                newNotif.append(deliveredHolder[i])
            }
        }
        appData.deliveredNotificationIDs = newNotif
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let categpryID = notification.request.content.threadIdentifier
        let notificationText = notification.request.content.body
        let catName = notification.request.content.title
        appData.deliveredNotificationIDs.append(notification.request.identifier)
        
        let okButton = IndicatorView.button(title: "OK", style: .standart, close: true) { _ in }
        let showButton = IndicatorView.button(title: "Show", style: .success, close: false) { _ in
          //  let load = LoadFromDB()
            LoadFromDB.shared.newCategories { categories, error in
                self.showHistory(categpry: categpryID)
            }
        }
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1007)
            self.ai.completeWithActions(buttons: (showButton, okButton), title: notificationText, descriptionText: "For category: \(catName)")
        }

    }
    
    
    func showHistory(categpry: String) {
        print("showHistory")

        let db = DataBase()
        if let categoryy = db.category(categpry) {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
                let navController = UINavigationController(rootViewController: vc)
                navController.navigationBar.tintColor = K.Colors.category
                navController.navigationBar.barTintColor = K.Colors.category
                navController.navigationBar.barStyle = .black
                navController.modalPresentationStyle = .pageSheet
                vc.historyDataStruct = db.transactions(for: categoryy)
                vc.selectedCategory = categoryy
                vc.fromCategories = true

                UIApplication.shared.windows.last?.rootViewController?.present(navController, animated: true, completion: {
                    DispatchQueue.main.async {
                        self.ai.fastHide { (_) in
                        }
                    }
                })

            }
        } else {
            DispatchQueue.main.async {
                self.ai.fastHide { (_) in
                    self.newMessage.show(title:"Category not found", type: .error)
                }
            }
        }
        
        
    }
    
    
}


protocol AppDelegateProtocol {
    func resighnActive()
}
