//
//  UIView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 28.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UIView {

    
    func shadow(opasity:Float = 0.6, black:Bool = false) {
        DispatchQueue.main.async {
            self.layer.shadowColor = !black ? K.Colors.secondaryBackground2.cgColor : UIColor.black.cgColor
            self.layer.shadowOffset = .zero
            self.layer.shadowRadius = 10
            self.layer.shadowOpacity = opasity
        }
    }
    
}
