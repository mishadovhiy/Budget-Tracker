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
            return .init(rawValue: dict["textColor"] as? String ?? "") ?? .secondary
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
    
    public static func with(
      _ populator: (inout Self) throws -> ()
    ) rethrows -> Self {
        var message = Self(dict: [:])
      try populator(&message)
      return message
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
        static let allCases:[TextAlighment] = [.left, .center, .right]
        
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
            get {
                return dict["img"] as? Data
            }
            set {
                if let data = newValue {
                    dict.updateValue(data, forKey: "img")
                } else {
                    dict.removeValue(forKey: "img")
                }
            }
        }
        
        var size:CGSize {
            get {
                return .create(dict["size"] as? [String:Float] ?? CGSize.init(width: 0.2, height: 0.2).dict)
            }
            set {
                dict.updateValue(newValue.dict, forKey: "size")
            }
        }
        
        var displeySize:CGSize {
            return .init(width: size.width * CGFloat(multiplierSize), height: size.height * CGFloat(multiplierSize))
        }
        
        let multiplierSize:Float = 200
        
        
        var inTextPosition:PdfTextProperties.InTextPosition {
            get {
                return .init(rawValue: dict["inTextPosition"] as? String ?? "") ?? .left
            }
            set {
                dict.updateValue(newValue.rawValue, forKey: "inTextPosition")
            }
        }
        
        public static func with(
          _ populator: (inout Self) throws -> ()
        ) rethrows -> Self {
            var message = Self(dict: [:])
          try populator(&message)
          return message
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
