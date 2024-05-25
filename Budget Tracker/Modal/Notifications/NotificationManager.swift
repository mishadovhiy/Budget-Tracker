//
//  NotificationManager.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 30.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//
#if canImport(UIKit)
import UIKit
#endif
import Foundation
struct NotificationManager {
    var db:DataBase {
        return AppDelegate.properties?.db ?? .init()
    }
    func loadNotifications(completion: @escaping ([String]) -> ()) {
        #if os(iOS)
        DispatchQueue.main.async {
            AppDelegate.properties?.center.getDeliveredNotifications(completionHandler: { nitof in
                var newIDs:[String] = []
                for i in 0..<nitof.count {
                    let requestID = nitof[i].request.identifier
                    newIDs.append(requestID)
                }
                newIDs += self.deliveredNotificationIDs
                completion(newIDs)
            })
        }
        #else
        
        #endif
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
                #if os(iOS)
                DispatchQueue.main.async {
                    Notifications.getNotificationsNumber()
                }
                #endif
            } else {
                db.db.removeValue(forKey: "deliveredNotificationIDs")
#if os(iOS)
                DispatchQueue.main.async {
                    Notifications.getNotificationsNumber()
                }
                #endif
            }
            
            
        }
    }
    
    
    mutating func removeAll() {
#if os(iOS)
        AppDelegate.properties?.center.removeAllDeliveredNotifications()
        #endif
        deliveredNotificationIDs = []
    }
   
}
