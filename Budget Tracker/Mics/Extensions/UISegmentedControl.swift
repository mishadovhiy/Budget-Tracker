//
//  UISegmentedControl.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 19.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if AppDelegate.shared?.deviceType != .mac {
            self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white], for: .normal)
            self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            
            if #available(iOS 13.0, *) {
                self.selectedSegmentTintColor = K.Colors.link
            } else {
                self.tintColor = K.Colors.link
            }
        }
    }
}
