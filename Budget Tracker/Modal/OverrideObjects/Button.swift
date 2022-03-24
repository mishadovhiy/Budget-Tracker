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
    
    @IBInspectable open var linkBackground = false {
        didSet {
            if linkBackground {
                DispatchQueue.main.async {
                    self.backgroundColor = K.Colors.link
                }
            }
        }
    }
    
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if let local = self.title(for: .normal)?.localize {
            DispatchQueue.main.async {
                self.setTitle(local, for: .normal)
            }
        }
        //set background for mac //fix when button background is always white
        
    }
    
    /**
     - set when you use SF Symbol as icon
     */
    @IBInspectable open var titleWhenNoSymbols: String = "" {
        didSet {
            
            if !AppDelegate.shared.symbolsAllowed && (titleWhenNoSymbols != "") {
                DispatchQueue.main.async {
                    self.setTitle(self.titleWhenNoSymbols.localize, for: .normal)
                    self.setImage(nil, for: .normal)
                    self.titleLabel?.font = .systemFont(ofSize: 15)
                    
                }
            }
            
        }
    }
    
    
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    
}
