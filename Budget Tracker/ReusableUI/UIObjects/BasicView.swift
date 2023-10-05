//
//  View.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 18.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

@IBDesignable
class BasicView: UIView {
    
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
    
    @IBInspectable open var lineColor: UIColor? = nil {
        didSet {
            if let color = lineColor {
                self.layer.borderWidth = borderWidth == 0 ? 2 : borderWidth
                self.layer.borderColor = color.cgColor
            }
        }
    }
    

    @IBInspectable open var shadowOpasity: Float = 0 {
        didSet {
            if !backgroundShadow {
                self.layer.shadow(opasity: shadowOpasity)
            }
        }
    }
    
    @IBInspectable open var backgroundShadow: Bool = false {
        didSet {
            if backgroundShadow {
                self.layer.shadow(opasity: 0.3, offset: .init(width: 2, height: 5), color: self.backgroundColor ?? .black, radius: 5)
            }
            
        }
    }
    
    @IBInspectable open var linkBackground:Bool = false {
        didSet {
            if linkBackground {
                self.backgroundColor = self.tintColor.withAlphaComponent(0.15)
            }
        }
    }
    
    


    
    
    @IBInspectable open var isOval: Bool = false {
        didSet {
            self.layer.cornerRadius = self.layer.frame.height / 2
        }
    }
}

