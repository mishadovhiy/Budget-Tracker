//
//  Dictionary.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 16.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

extension [String:Any]{
    var containsNil:Bool {
        var contains = false
        self.forEach {
            if let dict = $0.value as? [String:Any] {
                if dict.containsNil {
                    contains = true
                }
            }
        }
        return contains
    }
    
    
}
