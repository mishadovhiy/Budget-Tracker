//
//  AppDelegateExtensions.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 14.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit
import AVFoundation



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
