//
//  URL.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

extension URL {
    var components:[String] {
//        var vcName = self.absoluteString.replacingOccurrences(of: (self.scheme ?? "") + "://", with: "")
//        self.pathComponents.forEach({
//            vcName = vcName.replacingOccurrences(of: $0, with: "")
//        })
        let components = self.pathComponents.filter({$0 != "/"})
        return components
    }
}
