//
//  Date.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//
#if canImport(UIKit)
import UIKit
#endif

extension Date {
    var iso8601withFractionalSeconds: String {
        return Formatter.iso8601withFractionalSeconds.string(from: self)
        
    }
    var differenceFromNow: DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
    }
}

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
    }
}

extension Formatter {
    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}
