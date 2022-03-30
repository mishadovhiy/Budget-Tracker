//
//  UIDatePicker.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 30.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UIDatePicker {
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.tintColor = .white
        self.setValue(UIColor.white, forKey: "textColor")
    }
}

