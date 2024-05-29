//
//  LocalizationDict.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 19.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//
#if canImport(UIKit)
import UIKit
#endif
import Foundation

struct AppLocalization {
    
    static let dictionary:[String:[String:String]] = [
        "ua":localizationDictUA.dictUA
    ]
    
    
    static var launchedLocalization:String = "eng"
    
    static var udLocalization :String? {
        get {
            return AppDelegate.properties?.db.db["Localization"] as? String
        }
        set {
            AppDelegate.properties?.db.db.updateValue(newValue ?? "eng", forKey: "Localization")
        }
    }

}


