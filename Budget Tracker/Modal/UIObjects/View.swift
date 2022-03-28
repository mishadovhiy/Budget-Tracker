//
//  View.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 18.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

@IBDesignable
class View: UIView {

    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {
                self.layer.cornerRadius = self.cornerRadius
              //  self.layer.masksToBounds = self.cornerRadius > 0
            }
        }
    }
    /**
     -0.15
     -0.4
     */
    @IBInspectable open var shadowOpasity: Float = 0 {
        didSet {
            DispatchQueue.main.async {
                self.layer.shadowColor = K.Colors.secondaryBackground2.cgColor
                self.layer.shadowOffset = .zero
                self.layer.shadowRadius = 10//self.cornerRadius
                self.layer.shadowOpacity = self.shadowOpasity
            }
        }
        
    }

    @IBInspectable open var linkBackground:Bool = false {
        didSet {
            if linkBackground {
                DispatchQueue.main.async {
                    self.backgroundColor = K.Colors.link
                }
            }
        }
    }
    

}
