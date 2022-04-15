//
//  AppDelegate.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    static var shared:AppDelegate?
    let center = UNUserNotificationCenter.current()
    lazy var notificationManager = NotificationManager()
    
    let passcodeLock = PascodeLockView.instanceFromNib() as! PascodeLockView
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
    var bannerSize:CGFloat = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
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

        Notifications.getNotificationsNumber()
        
        AppLocalization.launchedLocalization = AppLocalization.udLocalization ?? (NSLocale.current.languageCode ?? "-")
        print("LOCALIZATION: ", AppLocalization.launchedLocalization)
        
        if !appData.proEnabeled {
            implementAdd()
        }
        
        return true
    }
    

    
    
    func applicationWillResignActive(_ application: UIApplication) {
        backgroundEnterDate = Date();
        if UserSettings.Security.password != "" && !(passcodeLock.presenting) {
            DispatchQueue.main.async {
                self.window?.endEditing(true)
            }
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
        guard let logoutDate = backgroundEnterDate else{
            if UserSettings.Security.password != "" {
                presentLock(passcode: true)
            }
            return;
        }
        let now = Date()
        let ti = now.timeIntervalSince(logoutDate)
        if !becameActive {
            becameActive = true
        } else {
            let fiveMin = Double(60 * 5)
            if ti > fiveMin {
                AppData.categoriesHolder = nil
                needDownloadOnMainAppeare = true
            }
        }
        if UserSettings.Security.password != "" {
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

protocol AppDelegateProtocol {
    func resighnActive()
}



