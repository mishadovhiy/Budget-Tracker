//
//  String.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 18.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import Foundation

extension String {

    var localize: String {
        let lang = AppLocalization.launchedLocalization
        return AppLocalization.dictionary[lang]?[self] ?? self
    }
    
    var filterNumber:Int? {
        return Int(Double(self.filter { "0123456789.".contains($0) }) ?? 0)
    }
    
    func slice(from: String, to: String) -> String? {
        var text:String?
        let _ = (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                text = String(self[substringFrom..<substringTo])
            }
        }
        
        return text
    }
    
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
}


extension String {
    
    var isAllNumbers:Bool {
        var result = true
        self.forEach {
            if !$0.isNumber {
                result = false
            }
        }
        return result
    }
    
    var isAllLetters:Bool {
        var ok = true
        self.forEach({
            if !$0.isLetter {
                ok = false
            }
        })
        return ok
    }
    
    var isAllEnglishLetters:Bool {
        var ok = true
        self.forEach({
            if !$0.isLetter {
                ok = false
            }
            if ok, let sc = $0.unicodeScalars.first,
               !CharacterSet.letters.contains(sc)
            {
                ok = false
            }
        })
        return ok
    }
    
    func stringToCompIso(dateFormat:String="dd.MM.yyyy") -> DateComponents {
        if let date = self.iso8601withFractionalSeconds {
            return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        } else {
            return stringToDateComponent(dateFormat: dateFormat)
        }
    }
    
    func stringToDateComponent(dateFormat:String="dd.MM.yyyy") -> DateComponents {
        let str = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: str)
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? Date())
    }

    var iso8601withFractionalSeconds: Date? {
        return Formatter.iso8601withFractionalSeconds.date(from: self)
        
    }
        
    func isoToDateComponents() -> DateComponents?  {
        return self == "" ? nil : stringToCompIso()
    }
}

extension Int {
    
    var stringMonth:String {
        let months = [1:"jan",
                      2:"feb",
                      3:"mar",
                      4:"apr",
                      5:"may",
                      6:"jun",
                      7:"jul",
                      8:"aug",
                      9:"sep",
                      10:"oct",
                      11:"nov",
                      12:"dec"]
        guard let res = months[self] else {
            return "\(self)"
        }
        return res.localize.capitalized
    }
    
    var twoDec:String {
        if self < 10 {
            return "0\(self)"
        } else {
            return "\(self)"
        }
    }
}


extension CGFloat {
    func validate(min:CGFloat) -> CGFloat {
        return self >= min ? self : min
    }
}

