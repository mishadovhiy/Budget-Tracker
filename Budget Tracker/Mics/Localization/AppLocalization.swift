//
//  LocalizationDict.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 19.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

struct AppLocalization {
    
    
    
    static var dict:[String:String]? {
        let loc = AppLocalization.launchedLocalization
        switch loc {
        case .ua:
            return localizationDictUA.dictUA
        case .eng:
            return nil
        }
    }
    
    static var launchedLocalization:Localization = .eng

    static func stringToLocalization(_ str: String?) -> Localization {
        switch str {
        case "eng":
            return .eng
        case "ua":
            return .ua
        default:
            return .eng
        }
    }
}


extension AppLocalization {
    enum Localization:String {
        case ua = "ua"
        case eng = "eng"
    }
}
