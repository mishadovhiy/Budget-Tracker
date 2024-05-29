//
//  ViewControllers.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 12.02.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif
extension DataBase {
    struct ViewControllers {
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
        }
        
        var ignoredActionTypes:[String] {
            get {
                return dict["ignoredActionTypes"] as? [String] ?? []
            }
            set {
                dict.updateValue(newValue, forKey: "ignoredActionTypes")
            }
        }
        
        var firstLaunch:[FirstLaunchVcs: Bool] {
            get {
                let ud = dict["firstLaunch"] as? [String: Bool] ?? [:]
                let array = ud.map { (key, value) in
                    return (FirstLaunchVcs.init(rawValue: key) ?? .home, value)
                }
                return Dictionary(uniqueKeysWithValues: array)
                
            }
            set {
                let array = newValue.map { (key, value) in
                    return (key.rawValue, value)
                }
                let newdict = Dictionary(uniqueKeysWithValues: array)
                self.dict.updateValue(newdict, forKey: "firstLaunch")
            }
        }
        
        enum FirstLaunchVcs:String {
            case home, statistic, categories
        }
        
        var trial:Trial {
            get {
                return .init(dict: dict["Trial"] as? [String:Any] ?? [:])
            }
            set {
                dict.updateValue(newValue.dict, forKey: "Trial")
                
            }
        }
        struct Trial {
            var dict:[String:Any]
            init(dict: [String : Any]) {
                self.dict = dict
            }
            
            var expireDays:Int {
                get {
                    return dict["trialToExpireDays"] as? Int ?? 0
                }
                set {
                    dict.updateValue(newValue, forKey: "trialToExpireDays")
                }
            }
            
            var checkTrial:Bool {
                get {
                    return dict["checkTrialDate"] as? Bool ?? true
                }
                set {
                    dict.updateValue(newValue, forKey: "checkTrialDate")
                }
            }
            
            var trialPressed:Bool {
                get {
                    return dict["trialPressed"] as? Bool ?? false
                }
                set {
                    dict.updateValue(newValue, forKey: "trialPressed")
                }
            }
        }
        
        
        var sortOption: [String:String] {
            get {
                let ud = dict["SortOption"] as? [String:String] ?? [:]
                return ud
                
            }
            set {
                dict.updateValue(newValue, forKey: "SortOption")
            }
        }
#if os(iOS)
        var pdfProperties:PDFProperties {
            get {
                return .init(dict: dict["pdfPropertiesd"] as? [String:Any] ?? [:])
            }
            set {
                dict.updateValue(newValue.dict, forKey: "pdfPropertiesd")
            }
        }
        #endif
        var cameraStorage:CameraVC {
            get {
                return .init(dict: dict["cameraStorage"] as? [String:Any] ?? [:])
            }
            set {
                dict.updateValue(newValue.dict, forKey: "cameraStorage")
            }
        }
        
        struct CameraVC {
            var dict:[String:Any]
            init(dict: [String : Any]) {
                self.dict = dict
            }
            
            var addTransactionCameraEnabled:Bool {
                get {
                    return dict["addTransactionCameraEnabled"] as? Bool ?? false
                }
                set {
                    dict.updateValue(newValue, forKey: "addTransactionCameraEnabled")
                }
            }
            
            var autoAddAll:Bool {
                get {
                    return dict["autoAddAll"] as? Bool ?? false
                }
                set {
                    dict.updateValue(newValue, forKey: "autoAddAll")
                }
            }
            
            
        }
        
    }
}

