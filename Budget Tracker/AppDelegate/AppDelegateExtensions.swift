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
        properties?.notificationManager.deliveredNotificationIDs.append(notification.request.identifier)
        let okButton:AlertViewLibrary.button = .init(title: "Close", style: .regular, close:true, action: nil)
        let showButton = AlertViewLibrary.button(title: "Show", style: .link, close: false) { _ in
            
            self.openNotification(notification)
            
        }
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1007)
            self.properties?.ai.showAlert(buttons: (showButton, okButton), title: notificationTitle, description: notificationText)
        }
        
    }
    
    
    func openNotification(_ notification:UNNotification) {
        let isDebts = notification.request.identifier.contains("Debts")
        let categpryID = notification.request.content.threadIdentifier

        if isDebts {
            LoadFromDB.shared.newCategories { categories, error in
                HistoryVC.showHistory(categpry: categpryID.replacingOccurrences(of: "Debts", with: ""))
            }
        } else {
            RemindersVC.showPaymentReminders()
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
                        HistoryVC.showHistory(categpry: cat.replacingOccurrences(of: "Debts", with: ""))
                    }
                }
            } else {
                properties?.newMessage.show(title:"Category not found".localize, type: .error)
            }
            
        } else {
            RemindersVC.showPaymentReminders()
        }
    }
    
}


extension AppDelegate: AlertViewProtocol {
    func alertViewWillAppear() {
    }
    
    func alertViewDidDisappear() {
    }
    
    
}

