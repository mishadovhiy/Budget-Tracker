//
//  UITapGestureRecognizer.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 08.02.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UITapGestureRecognizer {
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touchView = self.view as? TouchView {
            touchView.touchesEnded()
            self.state = .ended
        } else {
            self.state = .ended
        }
    }


    
    open override func ignore(_ touch: UITouch, for event: UIEvent) {
        super.ignore(touch, for: event)
        if let touchView = self.view as? TouchView {
            touchView.touchesEnded()
        }
    }
    
    open override func ignore(_ button: UIPress, for event: UIPressesEvent) {
        super.ignore(button, for: event)
        if let touchView = self.view as? TouchView {
            touchView.touchesEnded()
        }
    }
    
}
