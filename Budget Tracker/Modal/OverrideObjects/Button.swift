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
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if let local = self.title(for: .normal)?.localize {
            DispatchQueue.main.async {
                self.setTitle(local, for: .normal)
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
