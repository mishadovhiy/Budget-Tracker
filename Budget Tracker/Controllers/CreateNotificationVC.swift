//
//  CreateNotificationVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 04.03.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import UserNotifications

class CreateNotificationVC: UIViewController, UNUserNotificationCenterDelegate {
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        center.removeAllPendingNotificationRequests()
        center.delegate = self
        //UIApplication.shared.applicationIconBadgeNumber = 0
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    print("Yay!")
                } else {
                    print("D'oh")
                }
            }

    }
    

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresentwillPresent")
        print("received notification:", notification.request.content.body)
    }
    
    

    @IBAction func sendNotificationPressed(_ sender: UIButton) {
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
            // Notifications not allowed
          }
        }
        let content = UNMutableNotificationContent()
        content.title = "newnewnew"
        content.body = "Some body most likelly in a few lines"
        content.sound = UNNotificationSound.default
        let was = UIApplication.shared.applicationIconBadgeNumber
        content.badge = NSNumber(value: was + 1)
        content.categoryIdentifier = "Local Notification"
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.weekday = 5
       // dateComponents.year = 2021
     //   dateComponents.month = 3
        //dateComponents.day = 4
        dateComponents.hour = 20
        dateComponents.minute = 32

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    
        let request = UNNotificationRequest(identifier: "12.second.message",
                    content: content, trigger: trigger)
        

        //center.removeAllPendingNotificationRequests()
        
        center.add(request) { (error) in
            print(request)
            if error != nil {
                print("notif add error")
            } else {
                print("no errorrs")
            }
        }
    }
}
