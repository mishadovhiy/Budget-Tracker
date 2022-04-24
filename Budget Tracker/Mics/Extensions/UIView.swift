//
//  UIView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 28.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UIView {

    
    func shadow(opasity:Float = 0.6) {
        DispatchQueue.main.async {
            self.layer.shadowColor = K.Colors.secondaryBackground2.cgColor
            self.layer.shadowOffset = .zero
            self.layer.shadowRadius = 10//self.cornerRadius
            self.layer.shadowOpacity = opasity
        }
    }
    
}
