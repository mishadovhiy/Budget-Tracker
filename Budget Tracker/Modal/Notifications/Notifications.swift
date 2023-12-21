//
//  Notifications.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 25.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit



struct Notifications {
    
    private let center = AppDelegate.shared?.properties?.center
    
    
    static func removeNotification(id:String, pending:Bool = false) {
        DispatchQueue.main.async {
            AppDelegate.shared?.properties?.center.removeDeliveredNotifications(withIdentifiers: [id])
            if pending {
                AppDelegate.shared?.properties?.center.removePendingNotificationRequests(withIdentifiers: [id])
            }
            DispatchQueue(label: "db", qos: .userInitiated).async {
                let deliveredHolder = AppDelegate.shared?.properties?.notificationManager.deliveredNotificationIDs ?? []
                var newNotif:[String] = []
                for i in 0..<deliveredHolder.count {
                    if deliveredHolder[i] != id {
                        newNotif.append(deliveredHolder[i])
                    }
                }
                AppDelegate.shared?.properties?.notificationManager.deliveredNotificationIDs = newNotif
            }
        }
        
    }
    
    static func getNotificationsNumber() {
    //    DispatchQueue.main.async {
            AppDelegate.shared?.properties?.center.getDeliveredNotifications { notifications in
                var ids = AppDelegate.shared?.properties?.notificationManager.deliveredNotificationIDs ?? []
                for notification in notifications {
                    ids.append(notification.request.identifier)
                }
                var notificationsCount = (0,0)
                for id in ids {
                    let isDebt = id.contains("Debts")
                    if isDebt {
                        notificationsCount = ((notificationsCount.0 + 1), notificationsCount.1)
                    } else {
                        notificationsCount = (notificationsCount.0, (notificationsCount.1 + 1))
                    }
                }
                print(notificationsCount, "notificationsCountnotificationsCountnotificationsCount")
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = ids.count
                    HomeVC.shared?.notificationsCount = notificationsCount
                    Notifications.notificationsCount = notificationsCount
                    
                }
            }
      //  }
    }
    
    static var notificationsCount = (0,0)
    
    func addLocalNotification(date: DateComponents, title:String, id:String, body:String, completion: @escaping (Bool) -> ()) {
        print("adding for:", date)
        DispatchQueue.main.async {
            self.center?.removePendingNotificationRequests(withIdentifiers: [id])
            self.center?.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                completion(false)
          }
        }
        
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        content.categoryIdentifier = title
        content.threadIdentifier = id
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.year = date.year
        dateComponents.month = date.month
        dateComponents.day = date.day
        dateComponents.hour = date.hour
        dateComponents.minute = date.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id,
                    content: content, trigger: trigger)
            self.center?.add(request) { (error) in
                if error != nil {
                    completion(false)
                } else {
                    completion(true)

                }
            }
        }
    }
    
    
    
    static func requestNotifications() {
        DispatchQueue.main.async {
            AppDelegate.shared?.properties?.center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if !granted {
                    DispatchQueue.main.async {
                        AppDelegate.shared?.properties?.ai.showAlertWithOK(title: "Notifications not permitted".localize, text: "Allow to use user notifications for this app".localize, error: true, okTitle:"Go to settings".localize) { _ in
                            DispatchQueue.main.async {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url, options: [:]) { _ in
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

