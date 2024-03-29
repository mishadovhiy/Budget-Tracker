//
//  AppProperties.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 21.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit
import AlertViewLibrary
import MessageViewLibrary

class AppProperties {
    let center = UNUserNotificationCenter.current()
    lazy var notificationManager = NotificationManager()
    var selectedID:String = ""
    var firstLoadPasscode = true
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
    var coreDataManager:CoreDataDBManager?
    
    lazy var db:DataBase = {
        return DataBase()
    }()
    let appData = AppData()
    
    
    func aiNotShowingCondition() -> Bool {
        return db.username == ""
    }
    
    func setQuickActions() {
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
    }
}

extension AppProperties {
    private var appDelegate:AppDelegate {
        return UIApplication.shared.delegate as? AppDelegate ?? .init()
    }
    func appLoaded() {
        if coreDataManager != nil {
            return
        }
        coreDataManager = .init(persistentContainer: appDelegate.persistentContainer, appDelegate: appDelegate)
        DispatchQueue(label: "db", qos: .userInitiated).async {
            DataBase._db = self.coreDataManager?.fetch(.general)?.data?.toDict ?? [:]
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
                UIApplication.shared.sceneKeyWindow?.tintColor = tint
                self.center.delegate = self.appDelegate
                UNUserNotificationCenter.current().delegate = self.appDelegate
                Notifications.getNotificationsNumber()
                
                AppLocalization.launchedLocalization = localization
                print("LOCALIZATION: ", AppLocalization.launchedLocalization)
                
                if !pro {
                    self.banner.createBanner()
                }
                self.setQuickActions()
            }
        }
    }
    
    func receinActive() {
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
                    HomeVC.shared?.downloadFromDB()
                }
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
    func presentLock(passcode:Bool, passcodeVerified: (()->())? = nil ) {
        if passcode {
            
            passcodeLock.passcodeLock(passcodeEntered: passcodeVerified, appFirstLaunch: firstLoadPasscode)
            if firstLoadPasscode {
                firstLoadPasscode = false
            }
        } else {
            passcodeLock.present()
        }
        
    }
    
}

