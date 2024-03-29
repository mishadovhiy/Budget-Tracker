//
//  UIFont.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 16.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UIFont {
    func adjustSpacing(toMaxWidth maxWidth: CGFloat, string:NSAttributedString) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.font: self]
        let mutableString = NSMutableAttributedString(attributedString: string)
        
        while true {
            let currentWidth = mutableString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).width
            
            if currentWidth >= maxWidth {
                break
            }
            let range = NSRange(location: 0, length: mutableString.length)
            mutableString.mutableString.replaceOccurrences(of: " ", with: "  ", options: .literal, range: range)
        }
        return mutableString
    }
    
    
    func calculate(inWindth:CGFloat? = nil, attributes:[NSAttributedString.Key: Any]? = nil, string:String) -> CGSize {
        let fontSize = self.pointSize// ?? UIFont.systemFont(ofSize: 16)
        let defaultWidth = UIApplication.shared.sceneKeyWindow?.frame.width ?? 100
        var textAttributes: [NSAttributedString.Key: Any] = [.font: fontSize]
        attributes?.forEach({
            textAttributes.updateValue($0.value, forKey: $0.key)
        })
        let attributedText = NSAttributedString(string: string, attributes: textAttributes)
print(attributedText, " calculatecalculatecalculatecalculate")
        print(inWindth ?? defaultWidth, " wefdsa")
//crash
        let boundingRect = attributedText.boundingRect(with: CGSize(width: inWindth ?? defaultWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)

        return CGSize(width: ceil(boundingRect.size.width), height: ceil(boundingRect.size.height))

    }
}
