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
        var appearence:AIAppearence = aiAppearence()
        appearence.zPosition = 1001
        let ai = AlertViewLibrary.instanceFromNib(appearence)
        ai.notShowingCondition = aiNotShowingCondition
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
    
    lazy var db:DataBase = {
        return DataBase()
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.shared = self
        
        window?.tintColor = AppData.colorNamed(AppData.linkColor)
        center.delegate = self
        
        let today = appData.filter.getToday()
        let value = db.db["lastLaunching"] as? String ?? ""
        if value != today {
            db.db.updateValue(today, forKey: "lastLaunching")
            lastSelectedDate = nil
        }
        UNUserNotificationCenter.current().delegate = self
        Notifications.getNotificationsNumber()
        
        AppLocalization.launchedLocalization = AppLocalization.udLocalization ?? (NSLocale.current.languageCode ?? "-")
        print("LOCALIZATION: ", AppLocalization.launchedLocalization)
        
        if !appData.proEnabeled {
            banner.createBanner()
        }
        
        
        setQuickActions()
        return true
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
    
    enum ShortCodeItem:String {
        case addTransaction = "addTransaction"
        case addReminder = "addReminder"
        case monthlyLimits = "monthlyLimits"
        
        static var allCases:[ShortCodeItem] = [.addTransaction, .addReminder, .monthlyLimits]
        var item:Item {
            switch self {
            case .addTransaction:
                return .init(title: "Add Transaction", subtitle: "", icon: "plusLined")
            case .addReminder:
                return .init(title: "Add Reminder", subtitle: "", icon: "reminder")
            case .monthlyLimits:
                return .init(title: "Spending limits", subtitle: "", icon: "monthlyLimits")
            }
        }
        struct Item {
            let title:String
            let subtitle:String
            let icon:String
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let type = ShortCodeItem.init(rawValue: shortcutItem.type) else {
            print("unrecognized item pressed")
            return
        }
        var vc:UIViewController?
        switch type {
        case .addTransaction:
            vc = TransactionNav.configure()
        case .addReminder:
            self.showPaymentReminders()
            return
        case .monthlyLimits:
            let vcc = CategoriesVC.configure()
            vc = NavigationController(rootViewController: vcc)
        }
        if let vc = vc {
            self.present(vc: vc)
        }
    }

    func present(vc:UIViewController, completion:(()->())? = nil) {
        if let presenting = window?.rootViewController?.presentedViewController {
            presenting.dismiss(animated: true, completion: {
                self.present(vc: vc, completion: completion)
            })
        } else {
            window?.rootViewController?.present(vc, animated: true, completion: completion)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        DataBase._db = nil
        backgroundEnterDate = Date();
        DispatchQueue(label: "local", qos: .userInitiated).async {
            if UserSettings.Security.password != "" && !(self.passcodeLock.presenting) {
                DispatchQueue.main.async {
                    self.presentLock(passcode: false)
                }
                
            }
            self.db.db.updateValue(true, forKey: "BackgroundEntered")
        }
        
        self.window?.endEditing(true)
        if ViewController.shared?.sideBarShowing ?? false {
            ViewController.shared?.toggleSideBar(false, animated: true)
        }
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        DataBase._db = nil
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
        
        checkPasscodeTimout()
        if let backgroundEntered = db.db["BackgroundEntered"] as? Bool {
            if backgroundEntered != true {
                if !appData.devMode {
                    //send crash
                }
                
                /*              if appData.devMode {
                 DispatchQueue.main.async {
                 self.ai.showAlertWithOK(title:"Crash detected", text:"Crash logs has been sent to developer", error: true)
                 }
                 }*/
            }
        }
        db.db.updateValue(false, forKey: "BackgroundEntered")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print(#function)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print(#function)
        
    }
    

}

protocol AppDelegateProtocol {
    func resighnActive()
}



