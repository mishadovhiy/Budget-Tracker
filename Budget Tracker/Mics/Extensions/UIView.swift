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

extension CALayer {
    func shadow(opasity:Float = 0.6, offset:CGSize = .init(width: 0, height: 0), color:UIColor? = nil, radius:CGFloat = 10) {
        self.shadowColor = (color ?? .black).cgColor
        self.shadowOffset = offset
        self.shadowRadius = radius
        self.shadowOpacity = opasity
    }
}
