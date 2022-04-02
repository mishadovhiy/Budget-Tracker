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
            presentLock(passcode: false)
        }
    }
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        if appData.devMode {
            DispatchQueue.main.async {
                self.ai.showAlertWithOK(title: "Memory warning!", error: true)
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
        let notificationTitle = notification.request.content.title
        notificationManager.deliveredNotificationIDs.append(notification.request.identifier)
        let isDebts = notification.request.identifier.contains("Debts")
        let okButton = IndicatorView.button(title: "Close", style: .regular, close: true) { _ in }
        let showButton = IndicatorView.button(title: "Show", style: .link, close: false) { _ in
            
            if isDebts {
                LoadFromDB.shared.newCategories { categories, error in
                    self.showHistory(categpry: categpryID.replacingOccurrences(of: "Debts", with: ""))
                }
            } else {
                self.showPaymentReminders()
            }
            
        }
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1007)
            self.ai.showAlert(buttons: (showButton, okButton), title: notificationTitle, description: notificationText)
        }

    }
    
    
    func showHistory(categpry: String) {
        print("showHistory")

        let db = DataBase()
        if let categoryy = db.category(categpry) {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
              //  let navController = UINavigationController(rootViewController: vc)
                vc.historyDataStruct = db.transactions(for: categoryy)
                vc.selectedCategory = categoryy
                vc.fromCategories = true
                appData.present(vc: vc) { _ in
                    self.ai.fastHide()
                }

            }
        } else {
            let text = appData.devMode ? categpry : nil
            DispatchQueue.main.async {
                self.ai.showAlertWithOK(title:"Category not found".localize, text:text, error: true)
            }
        }
        
        
    }
    
    
    func showPaymentReminders() {
        DispatchQueue.main.async {
            let strorybpard = UIStoryboard(name: "Main", bundle: nil)
            let vc = strorybpard.instantiateViewController(withIdentifier: "RemindersVC") as! RemindersVC
            appData.present(vc: vc) { _ in
                self.ai.fastHide()
            }
            
        }
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
