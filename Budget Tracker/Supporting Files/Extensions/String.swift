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
            let loc = UserSettings.launchedLocalization
            switch loc {
            case .ua:
                return LocalizationDict.UADict[self] ?? self
            case .eng:
                return self
            }

        }
    }
}
