//
//  NotificationManager.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 30.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


struct NotificationManager {
    var db:DataBase {
        return AppDelegate.shared?.db ?? .init()
    }
    func loadNotifications(completion: @escaping ([String]) -> ()) {
        DispatchQueue.main.async {
            AppDelegate.shared?.center.getDeliveredNotifications(completionHandler: { nitof in
                var newIDs:[String] = []
                for i in 0..<nitof.count {
                    let requestID = nitof[i].request.identifier
                    newIDs.append(requestID)
                }
                newIDs += self.deliveredNotificationIDs
                completion(newIDs)
            })
        }
    }
    
    func containsUnseen(id:String, unseen:[String]) -> Bool {
        for val in unseen {
            if id == val {
                return true
            }
        }
        return false
    }
    
    var deliveredNotificationIDs: [String] {
        get {
            let result = db.db["deliveredNotificationIDs"] as? [String]
            print(result ?? ["-"], "deliveredNotificationIDs")
            return result ?? []
        }
        set {
            if newValue.count != 0 {
                self.db.db.updateValue(newValue, forKey: "deliveredNotificationIDs")
                DispatchQueue.main.async {
                    Notifications.getNotificationsNumber()
                }
            } else {
                db.db.removeValue(forKey: "deliveredNotificationIDs")

                DispatchQueue.main.async {
                    Notifications.getNotificationsNumber()
                }
            }
            
            
        }
    }
    
    
    mutating func removeAll() {
        AppDelegate.shared?.center.removeAllDeliveredNotifications()
        deliveredNotificationIDs = []
    }
   
}
