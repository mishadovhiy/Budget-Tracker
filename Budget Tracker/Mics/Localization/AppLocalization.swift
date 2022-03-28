//
//  LocalizationDict.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 19.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

struct AppLocalization {
    
    static let dictionary:[String:[String:String]] = [
        "ua":localizationDictUA.dictUA
    ]
    
    
    static var launchedLocalization:String = "eng"
    
    static var udLocalization :String? {
        get {
            return UserDefaults.standard.value(forKey: "Localization") as? String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "Localization")
        }
    }

}


