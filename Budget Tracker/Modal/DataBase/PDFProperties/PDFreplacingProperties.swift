//
//  PDFreplacingProperties.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 21.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

struct PDFreplacingProperties {
    var dict:[String:Any]
    init(dict: [String : Any]) {
        self.dict = dict
    }
    

    var date:DateType {
        get {
            return .init(dict: dict["date"] as? [String:Any] ?? [:])
        }
        set {
            dict.updateValue(newValue.dict, forKey: "date")
        }
    }
    
    struct DateType {
        var dict:[String:Any]
        init(dict: [String : Any]) {
            self.dict = dict
        }
        
        
        var type:DateTypeValue {
            get {
                return .init(rawValue: dict["DateTypeValue"] as? String ?? "") ?? .none
            }
            set {
                dict.updateValue(newValue.rawValue, forKey: "DateTypeValue")
            }
        }
        
        var rangeSeparetor:String {
            get {
                return dict["rangeSeparetor"] as? String ?? "-"
            }
            set {
                dict.updateValue(newValue, forKey: "rangeSeparetor")
            }
        }
        
        var format:DateTypeFormat {
            get {
                return .init(rawValue: dict["DateTypeFormat"] as? String ?? "") ?? .ddMMyyyy
            }
            set {
                dict.updateValue(newValue.rawValue, forKey: "DateTypeFormat")
            }
        }
        
        var dateSeparetor:String {
            get {
                return dict["dateSeparetor"] as? String ?? "."
            }
            set {
                dict.updateValue(newValue, forKey: "dateSeparetor")
            }
        }
    
        var inTextPosition:PdfTextProperties.InTextPosition {
            get {
                return .init(rawValue: dict["inTextPosition"] as? String ?? "") ?? .left
            }
            set {
                dict.updateValue(newValue.rawValue, forKey: "inTextPosition")
            }
        }
        
        
        enum DateTypeFormat:String {
            case mmDDyyy, monthDDyyyy, ddMMyyyy
            var title:String {
                switch self {
                case .mmDDyyy:
                    return "mm.dd.yyyy"
                case .monthDDyyyy:
                    return "Month DD, yyyy"
                case .ddMMyyyy:
                    return "dd.mm.yyyy"
                }
            }
            var compontns:[DateComponents.StringComponents] {
                switch self {
                case .mmDDyyy:
                    return [.mm, .dd, .yyyy]
                case .monthDDyyyy:
                    return [.month, .dd, .yyyy]
                case .ddMMyyyy:
                    return [.dd, .mm, .yyyy]
                }
            }
            static var allCases:[DateTypeFormat] = [
                .mmDDyyy, .ddMMyyyy//, .monthDDyyyy
            ]

        }
        
        enum DateTypeValue:String {
            case transactionDateRange, today, none
            var title:String {
                switch self {
                case .transactionDateRange:
                    return "Transaction days range"
                case .today:
                    return "Today"
                case .none:
                    return "None"
                }
            }
            static var allCases:[DateTypeValue] = [.transactionDateRange, .today, .none]
        }
    }
    
}
