//
//  AppDelegate.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import AlertViewLibrary
import MessageViewLibrary

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    static var shared:AppDelegate?
    let center = UNUserNotificationCenter.current()
    lazy var notificationManager = NotificationManager()
    
    
    var backgroundEnterDate:Date?
    var becameActive = false

    
    lazy var newMessage: MessageViewLibrary = {
        return MessageViewLibrary.instanceFromNib()
    }()
    
    lazy var ai: AlertViewLibrary = {
        let ai = AlertViewLibrary.instanceFromNib()
        return ai
    }()
    
    let passcodeLock = PascodeLockView.instanceFromNib() as! PascodeLockView
    
    lazy var banner: adBannerView = {
        return adBannerView.instanceFromNib() as! adBannerView
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
        AppDelegate.shared = self
        
        window?.tintColor = AppData.colorNamed(AppData.linkColor)
        center.delegate = self
        
        let today = appData.filter.getToday()
        let value = UserDefaults.standard.value(forKey: "lastLaunching") as? String ?? ""
        if value != today {
            UserDefaults.standard.setValue(today, forKey: "lastLaunching")
            lastSelectedDate = nil
        }

        Notifications.getNotificationsNumber()
        
        AppLocalization.launchedLocalization = AppLocalization.udLocalization ?? (NSLocale.current.languageCode ?? "-")
        print("LOCALIZATION: ", AppLocalization.launchedLocalization)
        
        if !appData.proEnabeled {
            banner.createBanner()
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
        UserDefaults.standard.setValue(true, forKey: "BackgroundEntered")
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        AnalyticModel.shared.analiticStorage.append(.init(key: #function.description, action: analiticName))
        AppData.categoriesHolder = nil
        if appData.devMode {
            DispatchQueue.main.async {
                self.ai.showAlertWithOK(title: "Memory warning!", error: true)
            }
        }
        
        print(#function)
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print(#function)
        AnalyticModel.shared.analiticStorage.append(.init(key: #function.description, action: analiticName))
        checkPasscodeTimout()
        if let backgroundEntered = UserDefaults.standard.value(forKey: "BackgroundEntered") as? Bool {
            if backgroundEntered != true {
                if !appData.devMode {
                    AnalyticModel.shared.analiticStorage.append(.init(key: "Crash", action: analiticName))
                }
                
                if appData.devMode {
                    DispatchQueue.main.async {
                        self.ai.showAlertWithOK(title:"Crash detected", text:"Crash logs has been sent to developer", error: true)
                    }
                }
            }
        }
        UserDefaults.standard.setValue(false, forKey: "BackgroundEntered")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print(#function)
    }
    private let analiticName = "AppDelegate"
    func applicationDidEnterBackground(_ application: UIApplication) {
        AnalyticModel.shared.analiticStorage.append(.init(key: #function.description, action: analiticName))
        AnalyticModel.shared.checkData()
        print(#function)
    }
    
    
}

protocol AppDelegateProtocol {
    func resighnActive()
}



