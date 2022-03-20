//
//  Button.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 17.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

@IBDesignable
class Button: UIButton {
    
    private var drawed = false
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !drawed {
            drawed = true
            DispatchQueue.main.async {
                self.setTitle(self.title(for: .normal)?.localize, for: .normal)
            }
        }
        
    }
    
    
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    
    @IBInspectable open var linkBackground: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.backgroundColor = K.Colors.link
            }
        }
    }
    
}
