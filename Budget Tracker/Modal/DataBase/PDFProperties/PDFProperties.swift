//
//  PDFProperties.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 06.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

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
        
        var from:DateComponents = .init()
        var to:DateComponents = .init()
        var today:DateComponents = .init()
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


