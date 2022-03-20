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
        get {
            let string = AppLocalization.dict?[self]
            if string == nil {
                print("//////////////// NO VALUE FOR:", self)
            }
            return string ?? self
        }
    }
    
    var iso8601withFractionalSeconds: Date? { return Formatter.iso8601withFractionalSeconds.date(from: self) }
    
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
