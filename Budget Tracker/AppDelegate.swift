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
    static var shared: AppDelegate?
    
    
    let center = UNUserNotificationCenter.current()
    
    lazy var newMessage: MessageView = {
        return MessageView.instanceFromNib() as! MessageView
    }()
    lazy var ai: IndicatorView = {
        let newView = IndicatorView.instanceFromNib() as! IndicatorView
        return newView
    }()
    

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        center.delegate = self
        AppDelegate.shared = self
        window?.backgroundColor = K.Colors.primaryBacground
        let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        let value = UserDefaults.standard.value(forKey: "lastLaunching") as? String ?? ""
        if value != today {
            UserDefaults.standard.setValue(today, forKey: "lastLaunching")
            lastSelectedDate = nil
            _categoriesHolder.removeAll()
        }

        
        print(today, "didFinishLaunchingWithOptions")
        
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        //
    }
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
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
        
    }
    func applicationWillTerminate(_ application: UIApplication) {
        print(#function)
    }

    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        let okButton = IndicatorView.button(title: "OK", style: .standart, close: true) { _ in
            
        }
        
        let showButton = IndicatorView.button(title: "Show", style: .success, close: false) { _ in
            let load = LoadFromDB()
            load.Debts { (loadedDebts, debtsError) in
                var debtsResult: [DebtsStruct] = []
                for i in 0..<loadedDebts.count {
                    let name = loadedDebts[i][1]
                    let amountToPay = loadedDebts[i][2]
                    let dueDate = loadedDebts[i][3]
                    debtsResult.append(DebtsStruct(name: name, amountToPay: amountToPay, dueDate: dueDate))
                }
                if debtsError == "" {
                    appData.saveDebts(debtsResult)
                }

               // DispatchQueue.main.async {
                 //   self.ai.fastHide { (_) in
                        self.showHistory(categpry: notification.request.content.threadIdentifier)
                //    }
                //}
            }
        }
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1007)
            self.ai.completeWithActions(buttons: (okButton, showButton), title: notification.request.content.title, descriptionText: notification.request.content.body)
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
