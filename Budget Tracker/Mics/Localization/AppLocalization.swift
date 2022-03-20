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
        case "ua":
            return localizationDictUA.dictUA
        default:
            return nil
        }
    }
    
    static var launchedLocalization:String = "eng"


}


