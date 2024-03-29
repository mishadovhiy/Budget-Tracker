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
    private var moveToWindow = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        setupLinkColors()
        if !moveToWindow {
            firstMovedToWindow()
        }
    }
    
    func firstMovedToWindow() {
        
    }
    
    @IBInspectable open var linkBackground:Bool = false {
        didSet {
            if linkBackground {
                self.backgroundColor = K.Colors.link
            }
        }
    }
    
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if let local = self.title(for: .normal)?.localize {
            self.setTitle(local, for: .normal)
        }
        if linkBackground {
            self.backgroundColor = K.Colors.link
        }
    }
    
    /**
     - set when you use SF Symbol as icon
     */
    @IBInspectable open var titleWhenNoSymbols: String = "" {
        didSet {
            
            if !(AppDelegate.properties?.appData.symbolsAllowed ?? true) && (titleWhenNoSymbols != "") {
                self.setTitle(self.titleWhenNoSymbols.localize, for: .normal)
                self.setImage(nil, for: .normal)
                self.titleLabel?.font = .systemFont(ofSize: 15)
            }
            
        }
    }
    
    
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable open var shadowOpasity: Float = 0 {
        didSet {
            self.layer.shadowColor = K.Colors.secondaryBackground2.cgColor
            self.layer.shadowOffset = .zero
            self.layer.shadowRadius = 10
            self.layer.shadowOpacity = self.shadowOpasity
        }
    }
    
    private func setupLinkColors() {
        if #available(iOS 15.0, *) {
            if self.backgroundColor == .tintColor {
                self.backgroundColor = K.Colors.link
            }
        } else if self.backgroundColor == .link {
            self.backgroundColor = K.Colors.link
        }
        if #available(iOS 15.0, *) {
            if self.tintColor == UIColor.tintColor {
                self.setTitleColor(K.Colors.link, for: .normal)
                self.tintColor = K.Colors.link
            }
        } else if self.tintColor == .link {
            self.tintColor = K.Colors.link
            self.setTitleColor(K.Colors.link, for: .normal)
        }
        
        if #available(iOS 15.0, *) {
            if self.titleColor(for: .normal) == UIColor.tintColor {
                self.setTitleColor(K.Colors.link, for: .normal)
                self.tintColor = K.Colors.link
            }
        } else if self.titleColor(for: .normal) == .link {
            self.tintColor = K.Colors.link
            self.setTitleColor(K.Colors.link, for: .normal)
        }
        if let touchButton = self as? TouchButton {
            if #available(iOS 15.0, *) {
                if touchButton.pressColor == .tintColor {
                    touchButton.pressColor = K.Colors.link
                }
            } else if touchButton.pressColor == .link {
                touchButton.pressColor = K.Colors.link
            }
        }
    }
}
