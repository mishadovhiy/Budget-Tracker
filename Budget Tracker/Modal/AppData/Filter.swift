//
//  Filter.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.02.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

extension AppData {
    
    struct Filter {
        //add init from dict
        var dict:[String:Any] = [:]
        init(dict: [String : Any]) {
            self.dict = dict
        }
        var showAll:Bool {
            get {
                return dict["showAlll"] as? Bool ?? false
            }
            set {
                dict.updateValue(newValue, forKey: "showAlll")
            }
        }
        var from: String {
            get {
                return dict["SortFromm"] as? String ?? ""
            }
            set {
                dict.updateValue(newValue, forKey: "SortFromm")

            }
        }
        var to: String {
            get {
                return dict["SortToo"] as? String ?? ""
            }
            set {
                dict.updateValue(newValue, forKey: "SortToo")

            }
        }
        var selectedPeroud:String {
            get {
                return dict["SortSelectedPeroudd"] as? String ?? ""
            }
            set {
                dict.updateValue(newValue, forKey: "SortSelectedPeroudd")
            }
        }
        
        var filteredData:[String: [String]] {
            get {
                return dict["filterOptions"] as? [String: [String]] ?? [:]
            }
            set {
                dict.updateValue(newValue, forKey: "filterOptions")
            }
            
        }
        
        var toDate:DateComponents {
            return to.stringToCompIso()
        }
        var fromDate:DateComponents {
            return from.stringToCompIso()
        }
        
        var periodText:String {
            let showAll = showAll
            let tod = fromDate
            return (tod.month?.stringMonth ?? "-").localize.capitalized + ", \(tod.year ?? 0)"
        }
        
        func getLastDayOf(month: Int, year: Int) -> Int {
            
            let dateComponents = DateComponents(year: year, month: month)
            let calendar = Calendar.current
            let date = calendar.date(from: dateComponents)!

            let range = calendar.range(of: .day, in: .month, for: date)!
            return range.count
        
        }
        
        func getLastDayOf(fullDate: String) -> Int {
            
            if fullDate != "" {
                let month = getMonthFromString(s: fullDate)
                let year = getMonthFromString(s: fullDate)
                
                let dateComponents = DateComponents(year: year, month: month)
                let calendar = Calendar.current
                let date = calendar.date(from: dateComponents)!

                let range = calendar.range(of: .day, in: .month, for: date)!
                return range.count
            } else {
                return 28
            }
        
        }
        
        
        
        func getToday(dateformatter: String = "dd.MM.yyyy") -> String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateformatter
            let results = dateFormatter.string(from: Date())
            return results
        }
        
        func makeTwo(n: Int) -> String {
            if n < 10 {
                return "0\(n)"
            } else {
                return "\(n)"
            }
        }
        
        func getDayFromString(s: String) -> Int {
            
            if s != "" {
                var day = s
                for _ in 0..<8 {
                    day.removeLast()
                }
                return Int(day) ?? 23
            } else {
                return 11
            }
            
        }
        
        
        func getMonthFromString(s: String) -> Int {
            
            if s != "" {
                var month = s
                for _ in 0..<3 {
                    month.removeFirst()
                }
                for _ in 0..<5 {
                    month.removeLast()
                }
                return Int(month) ?? 11
            } else {
                return 11
            }
        }
        
        func getYearFromString(s: String) -> Int {
            
            if s != "" {
                var year = s
                for _ in 0..<6 {
                    year.removeFirst()
                }
                return Int(year) ?? 1996
                
            } else {
                return 1996
            }

        }
        
        
        
    }
}
