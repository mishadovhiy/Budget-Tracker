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
    static var shared:AppDelegate?
    let center = UNUserNotificationCenter.current()
    lazy var notificationManager = NotificationManager()
    
    private let passcodeLock = PascodeLockView.instanceFromNib() as! PascodeLockView
    private var backgroundEnterDate:Date?
    private var becameActive = false
    
    
    
    lazy var newMessage: MessageView = {
        return MessageView.instanceFromNib() as! MessageView
    }()
    lazy var ai: IndicatorView = {
        let newView = IndicatorView.instanceFromNib() as! IndicatorView
        return newView
    }()
    
    public lazy var deviceType:DeviceType = {
        if #available(iOS 13.0, *) {
            #if !os(iOS)
            return .mac
            #endif
            return .primary
        } else {
            return .underIos13
        }
    }()
    
    public lazy var symbolsAllowed:Bool = {
        return deviceType != .primary ? false : true
    }()
    
    
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AppDelegate.shared = self
        window?.tintColor = AppData.colorNamed(AppData.linkColor)
        center.delegate = self
        window?.backgroundColor = K.Colors.primaryBacground
        let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        let value = UserDefaults.standard.value(forKey: "lastLaunching") as? String ?? ""
        if value != today {
            UserDefaults.standard.setValue(today, forKey: "lastLaunching")
            lastSelectedDate = nil
        }
        
        
        
        print(today, "didFinishLaunchingWithOptions")
        center.getDeliveredNotifications { notifications in
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = notifications.count + (AppDelegate.shared?.notificationManager.deliveredNotificationIDs.count ?? 999)
            }
        }
        
        AppLocalization.launchedLocalization = AppLocalization.udLocalization ?? (NSLocale.current.languageCode ?? "-")
        print("LOCALIZATION: ", AppLocalization.launchedLocalization)
        

        
        return true
    }
    

    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        AppData.categoriesHolder = nil
        
        if UserSettings.Security.password != "" && !(passcodeLock.presenting ?? true) {
            DispatchQueue.main.async {
                self.window?.endEditing(true)
            }
            backgroundEnterDate = Date();
            //delegate.resighnActive()
            presentLock(passcode: false)
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print(#function)
        if !becameActive {
            becameActive = true
        } else {
            needDownloadOnMainAppeare = true
        }
        if UserSettings.Security.password != "" {
            //end editing tf of window-topViewController-view
            guard let logoutDate = backgroundEnterDate else{
                presentLock(passcode: true)
                
                return;
            }
            let now = Date()
            let ti = now.timeIntervalSince(logoutDate)
            let timeout = Double(UserSettings.Security.timeOut) ?? 15
            if ti > timeout {

                presentLock(passcode: true)
            } else {
                passcodeLock.hide()
                
            }
        }
        
    }
    func applicationWillTerminate(_ application: UIApplication) {
        print(#function)
    }
    
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let categpryID = notification.request.content.threadIdentifier
        let notificationText = notification.request.content.body
        let catName = notification.request.content.title
        notificationManager.deliveredNotificationIDs.append(notification.request.identifier)
        
        let okButton = IndicatorView.button(title: "OK", style: .standart, close: true) { _ in }
        let showButton = IndicatorView.button(title: "Show", style: .success, close: false) { _ in
            
            if notification.request.identifier.contains("Debt") {
                LoadFromDB.shared.newCategories { categories, error in
                    self.showHistory(categpry: categpryID)
                }
            } else {
                self.showPaymentReminders()
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
                    self.newMessage.show(title:("Category".localize + " " + "not found".localize), type: .error)
                }
            }
        }
        
        
    }
    
    
    func showPaymentReminders() {
        let strorybpard = UIStoryboard(name: "Main", bundle: nil)
        let vc = strorybpard.instantiateViewController(withIdentifier: "RemindersVC") as! RemindersVC
        let nav = UINavigationController(rootViewController: vc)
        UIApplication.shared.windows.last?.rootViewController?.present(nav, animated: true, completion: {
            DispatchQueue.main.async {
                self.ai.fastHide { (_) in
                }
            }
        })
    }
    
/// methods
    func removeNotification(id:String) {
        DispatchQueue.main.async {
            self.center.removeDeliveredNotifications(withIdentifiers: [id])
        }
        let deliveredHolder = notificationManager.deliveredNotificationIDs
        var newNotif:[String] = []
        for i in 0..<deliveredHolder.count {
            if deliveredHolder[i] != id {
                newNotif.append(deliveredHolder[i])
            }
        }
        notificationManager.deliveredNotificationIDs = newNotif
    }
    
}



extension AppDelegate {
    func presentLock(passcode:Bool, passcodeVerified: (()->())? = nil ) {
        if passcode {
            passcodeLock.passcodeLock(passcodeEntered: passcodeVerified)
        } else {
            passcodeLock.present()
        }
        
    }
    
}


extension AppDelegate {
    enum DeviceType {
        case primary
        case underIos13
        case mac
    }
}





protocol AppDelegateProtocol {
    func resighnActive()
}
