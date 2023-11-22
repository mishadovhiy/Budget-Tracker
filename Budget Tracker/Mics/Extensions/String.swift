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
    
    func createQR() -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    func calculate(font:UIFont? = nil, inWindth:CGFloat? = nil) -> CGSize {
        let fontSize = font ?? UIFont.systemFont(ofSize: 16.0)
        let defaultWidth = AppDelegate.shared?.window?.frame.width ?? 100
        let textAttributes: [NSAttributedString.Key: Any] = [.font: fontSize]
        let attributedText = NSAttributedString(string: self, attributes: textAttributes)

        let boundingRect = attributedText.boundingRect(with: CGSize(width: inWindth ?? defaultWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)

        return CGSize(width: ceil(boundingRect.size.width), height: ceil(boundingRect.size.height))

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
    
    func makeTwo() -> String {
        if self < 10 {
            return "0\(self)"
        } else {
            return "\(self)"
        }
        
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




extension NSAttributedString {
    func adjustSpacing(toMaxWidth maxWidth: CGFloat, usingFont font: UIFont) -> NSAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        
        let mutableString = NSMutableAttributedString(attributedString: self)
        
        while true {
            let currentWidth = mutableString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).width
            
            if currentWidth >= maxWidth {
                break
            }
            
            // This example adds spaces between words. You may need to refine this based on your needs.
            let range = NSRange(location: 0, length: mutableString.length)
            mutableString.mutableString.replaceOccurrences(of: " ", with: "  ", options: .literal, range: range) // replace each space with two spaces
        }
        
        return mutableString
    }
}
