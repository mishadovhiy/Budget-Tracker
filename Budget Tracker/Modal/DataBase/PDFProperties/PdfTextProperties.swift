//
//  PdfTextProperties.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 21.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation
import UIKit

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
    
    
    var replacingType:PDFreplacingProperties {
        get {
            return .init(dict: dict["replacingType"] as? [String:Any] ?? [:])
        }
        set {
            dict.updateValue(newValue.dict, forKey: "replacingType")
        }
    }
    
    var attachment:AttachmentPdf {
        get {
            return .init(dict: dict["attachment"] as? [String:Any] ?? [:])
        }
        set {
            dict.updateValue(newValue.dict, forKey: "attachment")
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
    

    
    struct AttachmentPdf {
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
        }

        var img:Data? {
            return nil
        }
        
        var size:CGSize {
            return .init(width: 0, height: 0)
        }
        
        var inTextPosition:PdfTextProperties.InTextPosition {
            get {
                return .init(rawValue: dict["inTextPosition"] as? String ?? "") ?? .left
            }
            set {
                dict.updateValue(newValue.rawValue, forKey: "inTextPosition")
            }
        }
    }

    enum InTextPosition:String {
        case left, right
        var title:String {
            return rawValue.capitalized
        }
        static var allCases:[InTextPosition] = [.left, .right]
    }
}
