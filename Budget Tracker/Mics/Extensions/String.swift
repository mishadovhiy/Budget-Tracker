//
//  String.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 18.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension String {
    var localize: String {
        let lang = AppLocalization.launchedLocalization
        return AppLocalization.dictionary[lang]?[self] ?? self
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
    //time
    func stringToCompIso(dateFormat:String="dd.MM.yyyy") -> DateComponents {
        if let date = self.iso8601withFractionalSeconds {
            return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        } else {
            return stringToDateComponent(dateFormat: dateFormat)
        }
    }
    func stringToDateComponent(dateFormat:String="dd.MM.yyyy", string:String? = nil) -> DateComponents {//make privat
        let str = string ?? self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: str)
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date ?? Date())
    }
    
    var iso8601withFractionalSeconds: Date? {
        return Formatter.iso8601withFractionalSeconds.date(from: self)
        
    }
    
    
    
    func compToIso() -> DateComponents?  {
        return self == "" ? nil : stringToCompIso()
    }
}
