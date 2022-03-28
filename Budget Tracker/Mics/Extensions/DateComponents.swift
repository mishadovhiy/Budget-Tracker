//
//  DateComponents.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension DateComponents {
    var expired:Bool {
        if let dateDate = NSCalendar.current.date(from: self) {
            let difference = dateDate.differenceFromNow
            let one = (difference.second ?? 0) + (difference.minute ?? 0) + (difference.hour ?? 0)
            let expiredSeconds = one + (difference.day ?? 0) + (difference.month ?? 0) + (difference.year ?? 0)
            return expiredSeconds >= 0 ? true : false
        } else {
            return false
        }
    }
    
    func toIsoString() -> String? {
        if let date = Calendar.current.date(from: self){
            return date.iso8601withFractionalSeconds
        }
        return nil
    }
    func stringToDateComponent(s: String, dateFormat:String="dd.MM.yyyy") -> DateComponents {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: s)
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? Date())
    }
    
    func stringToCompIso(s: String, dateFormat:String="dd.MM.yyyy") -> DateComponents {
        if let date = s.iso8601withFractionalSeconds {
            return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        } else {
            return stringToDateComponent(s: s, dateFormat: dateFormat)
        }
    }
    
    
    func createDateComp(date:String, time:DateComponents?) -> DateComponents? {
        var date = time?.stringToCompIso(s: date)
        if let time = time {
            date?.second = time.second
            date?.minute = time.minute
            date?.hour = time.hour
            
        }
        return date
    }
    
}
