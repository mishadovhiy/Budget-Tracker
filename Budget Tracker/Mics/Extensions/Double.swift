//
//  Double.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 22.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

extension Double {
    var positive:Double {
        if self <= 0 {
            return self * -1
        } else {
            return self
        }
    }
    
    func string(_ decimals:Int = 2) -> String {
        return String(format: "%.\(decimals)f", self)

    }
}

extension Float {
    func string(_ decimals:Int = 2) -> String {
        return String(format: "%.\(decimals)f", self)
    }
}


extension CGSize {
    static func create(_ dict:[String:Float]) -> CGSize {
        return .init(width: CGFloat(dict["width"] ?? 0),
                     height: CGFloat(dict["height"] ?? 0))
    }
    var dict:[String:Float] {
        return [
            "width":Float(width),
            "height":Float(height)
        ]
    }
}
