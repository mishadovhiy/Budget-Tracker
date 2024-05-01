//
//  PdfDocumentProperties.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 21.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

struct PdfDocumentProperties {
    var dict:[String:Any]
    init(dict: [String : Any]) {
        self.dict = dict
    }
    
    var tableStyle:TableStyle {
        get {
            return .init(dict: dict["tableStyle"] as? [String:Any] ?? [:])
        }
        set {
            dict.updateValue(newValue.dict, forKey: "tableStyle")
        }
    }
    
    var colors:PdfColors {
        get {
            return .init(dict: dict["PdfColors"] as? [String:Any] ?? [:])
        }
        set {
            dict.updateValue(newValue.dict, forKey: "PdfColors")
        }
    }
    
    var textSizes: [PdfTextProperties.TextSize: Double] {
        get {
            let value = (dict["textSizes"] as? [String:Double]) ?? [:]
            let array = value.compactMap({
                return (PdfTextProperties.TextSize.init(rawValue: $0.key) ?? .small, $0.value)
            })
            return Dictionary(uniqueKeysWithValues: array)
        }
        set {
            let array = newValue.compactMap { (key: PdfTextProperties.TextSize, value: Double) in
                return (key.rawValue, value)
            }
            let new = Dictionary(uniqueKeysWithValues: array)
            
            dict.updateValue(new, forKey: "textSizes")
        }
    }

    
    struct PdfColors {
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
        }
        
        var background:CGColor {
            get {
                return getColor(defaultColor: K.Colors.background, color: dict["background"] as? String)
            }
            set {
                dict.updateValue(UIColor(cgColor: newValue).toHex, forKey: "background")
            }
            
        }
        
        var primary:CGColor {
            get {
                return getColor(defaultColor: K.Colors.category, color: dict["primary"] as? String)
            }
            set {
                dict.updateValue(UIColor(cgColor: newValue).toHex, forKey: "primary")
            }
        }
        
        var secondary:CGColor {
            get {
                return getColor(defaultColor: K.Colors.balanceT, color: dict["secondary"] as? String)
            }
            set {
                dict.updateValue(UIColor(cgColor: newValue).toHex, forKey: "secondary")
            }
        }
        
        var tint:CGColor {
            get {
                return getColor(defaultColor: K.Colors.link, color: dict["tintGet"] as? String)
            }
            set {
                dict.updateValue(UIColor(cgColor: newValue).toHex, forKey: "tintGet")
            }
        }
        
        
        
        func getColor(defaultColor:UIColor?, color:String?) -> CGColor {
            let defaultColor = defaultColor ?? .white
            if let value = color {
                if !value.contains("#") {
                    return (UIColor(named: value) ?? defaultColor).cgColor
                } else {
                    return (UIColor(hex: value) ?? defaultColor).cgColor
                    
                }
            } else {
                return defaultColor.cgColor
            }
        }
        
    }
    
}

extension PdfDocumentProperties {
    struct TableStyle {
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
        }
        
        var categorySepareted:Bool {
            get {
                dict["categorySepareted"] as? Bool ?? true
            }
            set {
                dict.updateValue(newValue, forKey: "categorySepareted")
            }
        }
    }
}
