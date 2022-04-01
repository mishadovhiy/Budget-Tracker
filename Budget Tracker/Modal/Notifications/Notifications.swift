//
//  Notifications.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 25.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit



struct Notifications {
    
    private let center = AppDelegate.shared?.center
    
    func addLocalNotification(date: DateComponents, title:String, id:String, body:String, completion: @escaping (Bool) -> ()) {
        print("adding for:", date)
        center?.removePendingNotificationRequests(withIdentifiers: [id])
        center?.getNotificationSettings { (settings) in
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
        DispatchQueue.main.async {
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
            AppDelegate.shared?.center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if !granted {
                    AppDelegate.shared?.ai.showAlertWithOK(title: "Notifications not permitted".localize, text: "Allow to use user notifications for this app".localize, error: true, okTitle:"Go to settings".localize) { _ in
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

