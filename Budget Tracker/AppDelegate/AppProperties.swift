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
    
    lazy var ai: AlertManager = {
        print("AlertManagerAlertManager")
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
    
    func aiAppearence() -> AIAppearence {
        let view = K.Colors.background ?? .red
        let background = UIColor.black
        let separetor = (K.Colors.separetor ?? .red).withAlphaComponent(0.5)
        
        return .with({
            $0.defaultText = .with({
                $0.loading = "Loading".localize
                $0.okButton = "OK".localize
                $0.error = "Error".localize
                $0.success = "Success".localize
                $0.internetError = ("Internet error".localize, "Try again later".localize)
                $0.standart = "Done".localize
                
            })
            $0.additionalLaunchProperties = .with({
                $0.mainCorners = 9
                $0.zPosition = 1001
            })
            $0.colors = .generate({
                $0.loaderBackAlpha = 0.25
                $0.alertBackAlpha = 0.5
                $0.loaderView = view.lighter()
                $0.view = view
                $0.background = background
                $0.separetor = separetor
                $0.texts = .with({
                    $0.title = K.Colors.category ?? .red
                    $0.description = K.Colors.balanceT ?? .red
                })
                $0.buttom = .with({
                    $0.link = K.Colors.link
                    $0.normal = K.Colors.category ?? .red
                })
                
            })
        })
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
        if coreDataManager != nil {
            return
        }
        coreDataManager = .init(persistentContainer: AppDelegate.shared!.persistentContainer, appDelegate: AppDelegate.shared!)
        DispatchQueue(label: "db", qos: .userInitiated).async {
            DataBase._db = self.coreDataManager?.fetch(.general)?.data?.toDict ?? [:]
            let today = self.appData.db.filter.getToday()
            let value = self.db.db["lastLaunching"] as? String ?? ""
            if value != today {
                self.db.db.updateValue(today, forKey: "lastLaunching")
                lastSelectedDate = nil
            }
            let pro = self.appData.db.proEnabeled
            let localization = AppLocalization.udLocalization ?? (NSLocale.current.languageCode ?? "-")
            let tint = UIColor(self.appData.db.linkColor)

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

