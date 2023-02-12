//
//  ViewControllers.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 12.02.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension DataBase {
    struct ViewControllers {
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
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
        case home, statistic
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
               /* var newString: String {
                    switch newValue {
                    case .id:
                        return "id"
                    case .name:
                        return "name"
                    case .transactionsCount:
                        return "transactionsCount"
                    }
                }

                ud.updateValue(newString, forKey: screenType.rawValue)*/
                dict.updateValue(newValue, forKey: "SortOption")
            }
        }

    }
}


