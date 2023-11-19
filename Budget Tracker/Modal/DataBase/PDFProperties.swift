//
//  PDFProperties.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 06.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

struct PDFProperties {
    var dict:[String:Any]
    init(dict: [String:Any]) {
        self.dict = dict
    }
    init() {
        self.dict = [:]
    }
    var defaultHeader:Bool {
        get {
            return dict["defaultHeader"] as? Bool ?? true
        }
        set {
            dict.updateValue(newValue, forKey: "defaultHeader")
        }
    }
    var needDate:Bool {
        get {
            return dict["needDate"] as? Bool ?? true
        }
        set {
            dict.updateValue(newValue, forKey: "needDate")
        }
    }
    var defaultFooter:Bool {
        get {
            return dict["defaultFooter"] as? Bool ?? true
        }
        set {
            dict.updateValue(newValue, forKey: "defaultFooter")
        }
    }
    var documentProperties:PdfDocumentProperties {
        get {
            return .init(dict: dict["PdfDocumentProperties"] as? [String:Any] ?? [:])
        }
        set {
            dict.updateValue(newValue.dict, forKey: "PdfDocumentProperties")
        }
    }
    
    var headers:[AdditionalPDFData] {
        get {
            return (dict["headers"] as? [[String:Any]])?.compactMap({.init(dict: $0)}) ?? []
        }
        set {
            let new:[[String:Any]] = newValue.compactMap({$0.dict})
            dict.updateValue(new, forKey: "headers")
        }
    }
    
    var footers:[AdditionalPDFData] {
        get {
            return (dict["footers"] as? [[String:Any]])?.compactMap({.init(dict: $0)}) ?? []
        }
        set {
            let new:[[String:Any]] = newValue.compactMap({$0.dict})
            dict.updateValue(new, forKey: "footers")
        }
    }
    
    var defaultHeaderData:DefaultHeaderData?
    
    public static func with(
      _ populator: (inout Self) throws -> ()
    ) rethrows -> Self {
        var message = Self()
      try populator(&message)
      return message
    }
    
    struct DefaultHeaderData {
        let duration:String
        /**
         - expenses, income, etc
         */
        let type:String
    }
}


struct PdfTextProperties {
    var dict:[String:Any]
    init(dict: [String:Any]) {
        self.dict = dict
    }
    
    var alighment:TextAlighment {
        get {
            return .init(rawValue: dict["alighment"] as? String ?? "") ?? .left
        }
        set {
            dict.updateValue(newValue.rawValue, forKey: "alighment")
        }
    }
    
    var textColor:PdfTextColor? {
        get {
            return .init(rawValue: dict["textColor"] as? String ?? "") ?? .primary
        }
        set {
            if let value = newValue {
                dict.updateValue(value.rawValue, forKey: "textColor")
            } else {
                dict.removeValue(forKey: "textColor")
            }
        }
    }
    
    var textSize:TextSize {
        get {
            return .init(rawValue: dict["textSize"] as? String ?? "") ?? .small
        }
        set {
            dict.updateValue(newValue.rawValue, forKey: "textSize")
        }
    }
    
    
    enum TextSize:String {
        case extraSmall
        case small
        case medium
        case big
        static let allCases:[TextSize] = [
            .extraSmall, .small, .medium, .big
        ]
        
        var size:(size:CGFloat, weight:UIFont.Weight) {
            switch self {
            case .small:
                return (size:12, weight:.regular)
            case .big:
                return (size:18, weight:.bold)
            case .extraSmall:
                return (size:9, weight:.regular)
            case .medium:
                return (size:14, weight:.regular)
            }
        }
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

struct PdfDocumentProperties {
    var dict:[String:Any]
    init(dict: [String : Any]) {
        self.dict = dict
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

struct AdditionalPDFData {
    var dict:[String:Any]
    init(dict: [String:Any]) {
        self.dict = dict
    }
    init() {
        self.dict = .init()
    }
    var custom:Custom? {
        get {
            return .init(dict: dict["custom"] as? [String:Any] ?? [:])
        }
        set {
            if let value = newValue {
                dict.updateValue(value.dict, forKey: "custom")
            } else {
                dict.removeValue(forKey: "custom")
            }
        }
    }
    public static func with(
      _ populator: (inout Self) throws -> ()
    ) rethrows -> Self {
        var message = Self()
      try populator(&message)
      return message
    }
    
    struct Custom {
        var dict:[String:Any]
        init(dict: [String:Any]) {
            self.dict = dict
        }
        init() {
            self.dict = .init()
        }
        var image:Data? = nil
        var title:String? {
            get {
                return dict["title"] as? String
            }
            set {
                if let value = newValue {
                    dict.updateValue(value, forKey: "title")
                } else {
                    dict.removeValue(forKey: "title")
                }
            }
        }
        var description:String? = nil
        var textSettins:PdfTextProperties {
            get {
                return .init(dict: dict["textSettins"] as? [String:Any] ?? [:])
            }
            set {
                dict.updateValue(newValue.dict, forKey: "textSettins")
            }
        }
        
        public static func with(
          _ populator: (inout Self) throws -> ()
        ) rethrows -> Self {
            var message = Self()
          try populator(&message)
          return message
        }
    }
    
}

enum PdfTextColor:String {
    case primary, secondary
    static let allCases:[PdfTextColor] = [
        .primary, .secondary
    ]
}
