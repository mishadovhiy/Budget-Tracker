//
//  AppProperties.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 21.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//
#if canImport(UIKit)
import UIKit
#endif
#if os(iOS)
import AlertViewLibrary
import MessageViewLibrary
#endif

class AppProperties {
#if os(iOS)
    let center = UNUserNotificationCenter.current()
    #endif
    lazy var notificationManager = NotificationManager()
    var selectedID:String = ""
    var firstLoadPasscode = true
#if os(iOS)
    lazy var newMessage: MessageViewLibrary = {
        return MessageViewLibrary.instanceFromNib()
    }()
    
    lazy var ai: AlertManager = {
        let ai = AlertManager()
        ai.setIgnorPresentLoader(self.aiNotShowingCondition)
        return ai
    }()
    let passcodeLock = PascodeLockView.instanceFromNib() as! PascodeLockView
    
    lazy var banner: adBannerView = {
        return adBannerView.instanceFromNib() as! adBannerView
    }()
    #endif
    var coreDataManager:CoreDataDBManager?
    var actionFromAppDelegate:(()->())? = nil
    lazy var db:DataBase = {
        return DataBase()
    }()
    let appData = AppData()
    
    
    func aiNotShowingCondition() -> Bool {
        return db.username == ""
    }
    
    init() {
        appLoaded()
    }
    
    func setQuickActions() {
#if os(iOS)
        DispatchQueue(label: "db", qos: .userInitiated).async {
            let ignored = DataBase().viewControllers.ignoredActionTypes
            var res: [UIApplicationShortcutItem] = []
            ShortCodeItem.allCases.forEach({
                if !ignored.contains($0.rawValue) {
                    res.append(.init(type: $0.rawValue, localizedTitle: $0.item.title, localizedSubtitle: $0.item.subtitle, icon: .init(templateImageName: $0.item.icon)))
                }
            })
            DispatchQueue.main.async {
                UIApplication.shared.shortcutItems = res

            }
        }
        #endif
    }
}

extension AppProperties {
    private var appDelegate:AppDelegate {
#if os(iOS)
        return UIApplication.shared.delegate as? AppDelegate ?? .init()
        #else
        return AppDelegate.shared ?? .init()
        #endif
    }
    
    func appLoaded() {
#if os(iOS)
        if coreDataManager != nil {
            return
        }
        #endif
        coreDataManager = .init(persistentContainer: appDelegate.persistentContainer, appDelegate: appDelegate)
        DispatchQueue(label: "db", qos: .userInitiated).async {
            #if os(iOS)
            DataBase._db = self.coreDataManager?.fetch(.general)?.data?.toDict ?? [:]
            #else
            DataBase._db = UserDefaults(suiteName: "group.com.dovhiy.detectAppClose")!.value(forKey: "DB") as? [String:Any]
            #endif
            let today = self.db.filter.getToday()
            let value = self.db.db["lastLaunching"] as? String ?? ""
            if value != today {
                self.db.db.updateValue(today, forKey: "lastLaunching")
                self.db.transactionDate = nil
            }
            let pro = self.db.proEnabeled
            let localization = AppLocalization.udLocalization ?? (NSLocale.current.languageCode ?? "-")
            let tint = UIColor(self.db.linkColor)

            DispatchQueue.main.async {
                #if os(iOS)
                UIApplication.shared.sceneKeyWindow?.tintColor = tint
                UNUserNotificationCenter.current().delegate = self.appDelegate
                self.center.delegate = self.appDelegate
                Notifications.getNotificationsNumber()
#endif
                AppLocalization.launchedLocalization = localization
                print("LOCALIZATION: ", AppLocalization.launchedLocalization)
                
                if !pro {
#if os(iOS)
                    self.banner.createBanner()
                    #endif
                }
                self.setQuickActions()
            }
        }
    }
    
    func receinActive() {
#if os(iOS)
        appData.backgroundEnterDate = Date();
        DispatchQueue(label: "local", qos: .userInitiated).async {
            if UserSettings.Security.password != "" && !(self.passcodeLock.presenting) {
                DispatchQueue.main.async {
                    self.presentLock(passcode: false)
                    
                }
                
            }
            self.db.db.updateValue(true, forKey: "BackgroundEntered")
        }
        
        UIApplication.shared.sceneKeyWindow?.endEditing(true)
        #endif
    }
    
    func becomeActive() {
        checkPasscodeTimout()
        DispatchQueue(label: "db", qos: .userInitiated).async {
            self.db.db.updateValue(false, forKey: "BackgroundEntered")
        }
    }
    
    func checkPasscodeTimout() {
        guard let logoutDate = appData.backgroundEnterDate else{
            if UserSettings.Security.password != "" {
                presentLock(passcode: true)
            }
            return;
        }
        let now = Date()
        let ti = now.timeIntervalSince(logoutDate)
        if !(appData.becameActive) {
            appData.becameActive = true
        } else {
            let fiveMin:Double = Double(60 * 3)//appData.devMode ? 0.1 : Double(60 * 3)
            if ti > fiveMin {
                if db.username != "" {
                    appData.needDownloadOnMainAppeare = false
#if os(iOS)
                    HomeVC.shared?.downloadFromDB()
                    #endif
                }
            }
        }
        if UserSettings.Security.password != "" {
            let timeout = Double(UserSettings.Security.timeOut) ?? 15
            if ti > timeout {
               presentLock(passcode: true)
            } else {
#if os(iOS)
                passcodeLock.hide()
                #endif
            }
        }
    }
    func presentLock(passcode:Bool, passcodeVerified: (()->())? = nil ) {
        if passcode {
#if os(iOS)
            passcodeLock.passcodeLock(passcodeEntered: passcodeVerified, appFirstLaunch: firstLoadPasscode)
            #endif
            if firstLoadPasscode {
                firstLoadPasscode = false
            }
        } else {
#if os(iOS)
            passcodeLock.present()
            #endif
        }
        
    }
    
}

