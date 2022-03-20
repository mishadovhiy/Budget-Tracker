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
            let string = AppLocalization.dict?[self]
            if string == nil {
                print("//////////////// NO VALUE FOR:", self)
            }
            return string ?? self
        }
    }
}
