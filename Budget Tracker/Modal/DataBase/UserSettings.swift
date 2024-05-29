//
//  UserSettings.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 16.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
struct UserSettings {
    static var dict:[String:Any] {
        get {
            return AppDelegate.properties?.db.db["UserSettingsDict"] as? [String:Any] ?? [:]
        }
        set {
            AppDelegate.properties?.db.db.updateValue(newValue, forKey: "UserSettingsDict")
        }
    }
    
    struct Security {
        static var password:String {
            get {
                
                return UserSettings.dict["password"] as? String ?? ""
            }
            set {
                UserSettings.dict["password"] = newValue
            }
        }
        
        static var timeOut:String {
            get {
                return UserSettings.dict["timeOut"] as? String ?? "15"
            }
            set {
                UserSettings.dict["timeOut"] = newValue
            }
        }
    }
}
