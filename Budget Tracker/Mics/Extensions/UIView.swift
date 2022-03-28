//
//  UIView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 28.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UIView {
    func shadow(opasity: Float = 0.4, radius:CGFloat? = 9, color: UIColor = K.Colors.secondaryBackground) {
        DispatchQueue.main.async {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = opasity
            self.layer.shadowOffset = .zero
            self.layer.shadowRadius = 12
            if let radius = radius {
                self.layer.cornerRadius = radius
            }
            
            self.backgroundColor = color
        }
    }
}
