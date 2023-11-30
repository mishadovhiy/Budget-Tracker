//
//  AppDelegateExtensions.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 14.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import AVFoundation
import AlertViewLibrary


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        self.openNotification(response.notification)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationText = notification.request.content.body
        let notificationTitle = notification.request.content.title
        notificationManager.deliveredNotificationIDs.append(notification.request.identifier)
        let okButton:AlertViewLibrary.button = .init(title: "Close", style: .regular, close:true, action: nil)
        let showButton = AlertViewLibrary.button(title: "Show", style: .link, close: false) { _ in
            
            self.openNotification(notification)
            
        }
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1007)
            self.ai.showAlert(buttons: (showButton, okButton), title: notificationTitle, description: notificationText)
        }
        
    }
    
    
    func openNotification(_ notification:UNNotification) {
        let isDebts = notification.request.identifier.contains("Debts")
        let categpryID = notification.request.content.threadIdentifier

        if isDebts {
            LoadFromDB.shared.newCategories { categories, error in
                self.showHistory(categpry: categpryID.replacingOccurrences(of: "Debts", with: ""))
            }
        } else {
            self.showPaymentReminders()
        }
    }
    
    func showHistory(categpry: String) {
        let db = DataBase()
        if let categoryy = db.category(categpry) {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
                let navController = UINavigationController(rootViewController: vc)
                vc.fromAppDelegate = true
                vc.historyDataStruct = db.transactions(for: categoryy)
                vc.selectedCategory = categoryy
                vc.fromCategories = true
                self.appData.present(vc: navController) { _ in
                    self.ai.fastHide()
                }
                navController.setBackground(.regular)
                
            }
        } else {
            let text = appData.devMode ? categpry : nil
            DispatchQueue.main.async {
                self.ai.showAlertWithOK(title:"Category not found".localize, text:text, error: true)
            }
        }
        
        
    }
        
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url, " gvchjn")
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        let isDebts = notification?.request.identifier.contains("Debts")
        let categpryID = notification?.request.content.threadIdentifier
        
        if isDebts ?? false {
            if let cat = categpryID {
                DispatchQueue.init(label: "local", qos: .userInitiated).async {
                    LoadFromDB.shared.newCategories { categories, error in
                        self.showHistory(categpry: cat.replacingOccurrences(of: "Debts", with: ""))
                    }
                }
            } else {
                self.newMessage.show(title:"Category not found".localize, type: .error)
            }
            
        } else {
            self.showPaymentReminders()
        }
    }
    
    
    func showPaymentReminders() {
        DispatchQueue.main.async {
            let strorybpard = UIStoryboard(name: "Main", bundle: nil)
            let vc = strorybpard.instantiateViewController(withIdentifier: "RemindersVC") as! RemindersVC
            vc.fromAppDelegate = true
            let nav = UINavigationController(rootViewController: vc)
            self.appData.present(vc: nav) { _ in
                self.ai.fastHide()
            }
            
            nav.setBackground(.regular)
        }
    }
    
    
    func checkPasscodeTimout() {
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
            let fiveMin:Double = appData.devMode ? 0.1 : Double(60 * 3)
            if ti > fiveMin {
                if appData.username != "" {
                    AppData.categoriesHolder = nil
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



extension AppDelegate: AlertViewProtocol {
    func alertViewWillAppear() {
    }
    
    func alertViewDidDisappear() {
    }
    
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
        return appData.username == ""
    }
}


extension AppDelegate {
    enum DeviceType:String {
        case primary = "primary"
        case underIos13 = "underIos13"
        case mac = "mac"
    }
}

