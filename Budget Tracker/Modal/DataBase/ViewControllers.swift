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

        struct PDFProperties {
            var dict:[String:Any]
            init(dict: [String:Any]) {
                self.dict = dict
            }
            
            var text:PdfTextProperties? {
                get {
                    return .init(dict: dict["PdfTextProperties"] as? [String:Any] ?? [:])
                }
                set {
                    if let value = newValue {
                        dict.updateValue(value, forKey: "PdfTextProperties")
                    } else {
                        dict.removeValue(forKey: "PdfTextProperties")
                    }
                }
            }
        }
        
    }
}

struct PdfTextProperties {
    var dict:[String:Any]
    init(dict: [String:Any]) {
        self.dict = dict
    }
    
    var alighment:TextAlighment {
        get {
            return .init(rawValue: dict["alighment"] as! String) ?? .left
        }
        set {
            dict.updateValue(newValue, forKey: "alighment")
        }
    }
    
    var textColor:String? {
        get {
            return dict["textColor"] as? String
        }
        set {
            if let value = newValue {
                dict.updateValue(value, forKey: "textColor")
            } else {
                dict.removeValue(forKey: "textColor")
            }
        }
    }

    var textSize:TextSize {
        get {
            return .init(rawValue: dict["textSize"] as! String) ?? .small
        }
        set {
            dict.updateValue(newValue, forKey: "textSize")
        }
    }
    
    
    enum TextSize:String {
        case small
        case big
    }
    enum TextAlighment:String {
        case center, right, left
        static let allCases:[TextAlighment] = [.center, .right, .left]
        
        var textAligment:NSTextAlignment {
            switch self {
            case .center:
                return .center
            case .right:
                return .right
            case .left:
                return .left
            }
        }
    }
}

