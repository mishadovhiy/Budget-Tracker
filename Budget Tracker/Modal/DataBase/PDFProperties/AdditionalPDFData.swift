//
//  AdditionalPDFData.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 21.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

struct AdditionalPDFData {
    var dict:[String:Any]
    init(dict: [String:Any]) {
        self.dict = dict
    }
    var isDefault:Bool = false
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
        var message = Self(dict: [:])
      try populator(&message)
      return message
    }
    
    struct Custom {
        var dict:[String:Any]
        init(dict: [String:Any]) {
            self.dict = dict
        }

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
            var message = Self(dict: [:])
          try populator(&message)
          return message
        }
    }
    
}
