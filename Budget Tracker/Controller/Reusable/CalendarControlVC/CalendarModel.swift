//
//  CalendarModel.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 08.10.2022.
//

import UIKit

struct CalendarData:Hashable, Identifiable {
    var id: ObjectIdentifier? {
        return nil
    }
    
    let year:Int
    let month:Int
    
    var identifier: String {
        return UUID().uuidString
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    static func == (lhs: CalendarData, rhs: CalendarData) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.identifier == rhs.identifier
    }
}

class CalendarModel {
    
    init(_ data:CalendarData) {
        self.year = data.year
        self.month = data.month
        self.days = getDays()
        
    }
    
    var description:String {
        return "year:\(self.year), month:\(self.month), \ndays:\(self.days)"
    }
    
    
    var year = 1996
    var month = 11
    
    var days = [0]
    var daystoWeekStart = 0
    
    var upToFour = (0,0)
    
    lazy var today:DateComponents = {
        return getToday()
    }()
    
    
    
    func getDays() -> [Int]  {
        daystoWeekStart = 0
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        days.removeAll()
        
        var resultDays:[Int] = []
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let strDate = "\(year)-\(makeTwo(month))-02"
        let datee = formatter.date(from: strDate)
        let calendarr = Calendar(identifier: .gregorian)
        let weekNumber = calendarr.component(.weekday, from: datee ?? Date())-3
        
        let weekRes = weekNumber < 0 ? 7 + weekNumber : weekNumber
        daystoWeekStart = weekRes
        for _ in 0..<weekRes{
            resultDays.append(0)
        }
        for i in 0..<numDays {
            resultDays.append(i+1)
        }
        self.days = resultDays
        return resultDays
        
        /*DispatchQueue.main.async {
         self.monthTF.text = "\(self.returnMonth(self.month)), \(self.year)"
         self.daysLoaded()
         }*/
        
        
    }
    
    
    func getToday() -> DateComponents {
        let now = Date()
        return now.toDateComponents()
    }
    
    func makeTwo(_ int: Int?) -> String {
        if let n = int {
            return n <= 9 ? "0\(n)" : "\(n)"
        } else {
            return "00"
        }
    }
    
    func returnMonth(_ month: Int) -> String {
        
        return month.stringMonth
    }
    
    func setYear() {
        if month == 13 {
            month = 1
            year = year + 1
        }
        if month == 0 {
            month = 12
            year = year - 1
        }
    }
    
    
    func setMonth(_ month:Int) {
        self.month = month//sender.tag == 0 ? model.month - 1 : model.month + 1
        self.setYear()
        self.days = self.getDays()
    }
}




extension Date {
    func toDateComponents() -> DateComponents {
        let string = self.iso8601withFractionalSeconds
        let comp = DateComponents()
        return comp.stringToCompIso(s: string)
    }
    
    
    /* var differenceFromNow: DateComponents {
     return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
     }*/
}




extension DateComponents {
    var desription:String {
        return "\(self.day ?? 0).\(self.month ?? 0).\(self.year ?? 0)"
    }
    /*func toIsoString() -> String? {
     if let date = Calendar.current.date(from: self){
     return date.iso8601withFractionalSeconds
     }
     return nil
     }
     
     func stringToCompIso(s: String, dateFormat:String="dd.MM.yyyy") -> DateComponents {
     if let date = s.iso8601withFractionalSeconds {
     return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
     } else {
     return stringToDateComponent(s: s, dateFormat: dateFormat)
     }
     }
     
     private func stringToDateComponent(s: String, dateFormat:String="dd.MM.yyyy") -> DateComponents {//make privat
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = dateFormat
     let date = dateFormatter.date(from: s)
     return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? Date())
     }
     
     
     func createDateComp(date:String, time:DateComponents?) -> DateComponents? {
     var date = time?.stringToCompIso(s: date)
     if let time = time {
     date?.second = time.second
     date?.minute = time.minute
     date?.hour = time.hour
     
     }
     return date
     }*/
}


