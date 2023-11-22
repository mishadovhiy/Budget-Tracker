//
//  DateComponents.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension DateComponents {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        return calendar.date(byAdding: lhs, to: now)! < calendar.date(byAdding: rhs, to: now)!
    }
    
    var expired:Bool {
        if let dateDate = NSCalendar.current.date(from: self) {
            return dateDate.toDateComponents() < Date().toDateComponents() 
        } else {
            return true
        }
      /*  if let dateDate = NSCalendar.current.date(from: self) {
            let dif = dateDate.differenceFromNow
           /* let one = (difference.second ?? 0) + (difference.minute ?? 0) + (difference.hour ?? 0)
            let expDays = (difference.day ?? 0) + (difference.month ?? 0) + (difference.year ?? 0)
            if expDays <= 0 {
                return (difference.hour ?? 0) <= 0 && (difference.minute ?? 0) <= 0 ? false : true
            } else {
                return true
            }*/
            print(dif, "fgedfgdfhrt")
            if intOk(dif.year) && intOk(dif.month) && intOk(dif.day) {
                if intOk(dif.hour)  {
                    return false
                } else {
                    return !intOk(dif.minute)
                }
            } else {
                return true
            }
            
         //   let expiredSeconds = one + expDays :
         //   return expiredSeconds >= 0 ? true : false
        } else {
            return true
        }*/
    }
    private func intOk(_ int:Int?) -> Bool {
        return int ?? 0 > 0 ? false : true
    }
    func toIsoString() -> String? {
        if let date = Calendar.current.date(from: self){
            return date.iso8601withFractionalSeconds
        }
        return nil
    }
    
    var timeString:String {
        return "\(hour?.makeTwo() ?? "01"):\(minute?.makeTwo() ?? "01")"
    }
    
    var textDate:String {
        return "\((self.month?.stringMonth ?? "").capitalized) \(self.day?.makeTwo() ?? "-"), \(self.year ?? 0)"
    }
    
    func toShortString(dateFormat:String="dd.MM.yyyy", components:[StringComponents] = [.dd, .mm, .yyyy], separetor:String = ".") -> String? {
        var text = ""
        components.forEach {
            text += stringComponent($0)
            if $0 != (components.last ?? .yyyy) {
                text += separetor
            }
        }
        return text
    }
    
    
    private func stringComponent(_ value:StringComponents) -> String {
        switch value {
        case .dd:
            return day?.twoDec ?? ""
        case .mm:
            return month?.twoDec ?? ""
        case .month:
            return month?.stringMonth ?? ""
        case .yyyy:
            return "\(year ?? 0)"
        }
    }
    
    enum StringComponents:String {
    case dd, mm, month, yyyy
    }
    
    
    func stringToDateComponent(s: String, dateFormat:String="dd.MM.yyyy") -> DateComponents {//make privat
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
    
    var lastDayOfMonth: Int? {
        let calendar = Calendar.current

        var dateComponents = DateComponents()
        dateComponents.calendar = calendar
            dateComponents.year = year
            dateComponents.month = month
        
        guard let firstDayOfNextMonth = calendar.date(from: dateComponents) else {
            return nil
        }

        if let lastDayOfMonth = calendar.date(byAdding: DateComponents(day: -1), to: firstDayOfNextMonth) {
            let day = calendar.component(.day, from: lastDayOfMonth)
            return day
        }
        
        return nil
    }
    
    //returnMonth() --- indeed : to do:replace!!!
    var stringMonth:String? {
        if let month = self.month {
            let monthes = [
                1: "Jan".localize, 2: "Feb".localize, 3: "Mar".localize, 4: "Apr".localize, 5: "May".localize, 6: "Jun".localize, 7: "Jul".localize, 8: "Aug".localize, 9: "Sep".localize, 10: "Oct".localize, 11: "Nov".localize, 12: "Dec".localize
            ]
            return monthes[month]
        } else {
            return nil
        }
    }
    


}

extension DateComponents:Comparable {
    
}
