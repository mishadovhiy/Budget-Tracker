//
//  UserSettings.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 16.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

struct UserSettings {
    

    static func stringToLocalization(_ str: String?) -> Localization {
        switch str {
        case "eng":
            return .eng
        case "ua":
            return .ua
        default:
            return .eng
        }
    }
    enum Localization:String {
        case ua = "ua"
        case eng = "eng"
    }
    
    static var launchedLocalization:Localization = .eng

    static var dict:[String:Any] {
        get {
            return UserDefaults.standard.value(forKey: "UserSettingsDict") as? [String:Any] ?? [:]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "UserSettingsDict")
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
                return UserSettings.dict["timeOut"] as? String ?? ""
            }
            set {
                UserSettings.dict["timeOut"] = newValue
            }
        }
    }
}
