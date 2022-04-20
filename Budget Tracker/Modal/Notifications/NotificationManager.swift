//
//  NotificationManager.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 30.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


struct NotificationManager {
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
            let result = UserDefaults.standard.value(forKey: "deliveredNotificationIDs") as? [String]
            print(result ?? ["-"], "deliveredNotificationIDs")
            return result ?? []
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "deliveredNotificationIDs")
            Notifications.getNotificationsNumber()
        }
    }
    
   
}