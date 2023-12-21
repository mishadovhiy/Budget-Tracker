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
    

    lazy var newMessage: MessageViewLibrary = {
        return MessageViewLibrary.instanceFromNib()
    }()
    
    lazy var ai: AlertViewLibrary = {
        let ai = AlertViewLibrary.instanceFromNib(aiAppearence())
        ai.notShowingCondition = aiNotShowingCondition
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
    
    func aiAppearence() -> AIAppearence {
        let texts:AIAppearence.Text = .init(loading: "Loading".localize, done: "Done".localize, internetError: (title: "Internet error".localize, description: "Try again later".localize), error: "Error".localize, okButton: "OK".localize, success: "Success".localize)
        
        let view = K.Colors.background ?? .red
        
        let background = UIColor.black
        
        let accent = (background: background.withAlphaComponent(0.7),
                      view: view.withAlphaComponent(0.8),
                      higlight: UIColor.red)
        
        let normal = (background: background.withAlphaComponent(0.5),
                      view: view.withAlphaComponent(0.6))
        
        let buttom = (link: K.Colors.link, normal: K.Colors.category ?? .red)
        
        let textsColor = (title: K.Colors.category ?? .red, description: K.Colors.balanceT ?? .red)
        
        let separetor = (K.Colors.separetor ?? .red).withAlphaComponent(0.5)
        
        let colors:AIAppearence.Colors = .init(accent: accent, normal: normal, buttom: buttom, texts: textsColor, separetor: separetor)
        var new:AIAppearence = .init(text: texts, colors: colors)
        new.zPosition = 1001

        return new
    }
    
    func aiNotShowingCondition() -> Bool {
        return appData.db.username == ""
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
    func appLoaded() {
        print(UIDevice.current.identifierForVendor?.uuidString, " identifierForVendor")
        coreDataManager = .init(persistentContainer: AppDelegate.shared!.persistentContainer, appDelegate: AppDelegate.shared!)
        DispatchQueue(label: "db", qos: .userInitiated).async {
            DataBase._db = self.coreDataManager?.fetch(.general)?.data?.toDict ?? [:]
            let tint = UIColor.linkColor
            let today = self.appData.db.filter.getToday()
            let value = self.db.db["lastLaunching"] as? String ?? ""
            if value != today {
                self.db.db.updateValue(today, forKey: "lastLaunching")
                lastSelectedDate = nil
            }
            let pro = self.appData.db.proEnabeled
            let localization = AppLocalization.udLocalization ?? (NSLocale.current.languageCode ?? "-")
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.tintColor = tint
                self.center.delegate = AppDelegate.shared
                UNUserNotificationCenter.current().delegate = AppDelegate.shared
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
        
        UIApplication.shared.keyWindow?.endEditing(true)
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
                if appData.db.username != "" {
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
            passcodeLock.passcodeLock(passcodeEntered: passcodeVerified)
        } else {
            passcodeLock.present()
        }
        
    }
    
}

