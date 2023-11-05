//
//  UIColor.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.02.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UIColor {

    public convenience init?(hex:String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            self.init(named: "CategoryColor")
            return
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    var toHex: String {
            if let components = self.cgColor.components, components.count >= 3 {
                let red = Int(components[0] * 255.0)
                let green = Int(components[1] * 255.0)
                let blue = Int(components[2] * 255.0)
                
                return String(format: "#%02X%02X%02X", red, green, blue)
            }
            
            return "#000000" // Default to black if unable to get color components
        }
    
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0

        
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )

        
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
    
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
    
    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: -1*componentDelta)
    }
}
