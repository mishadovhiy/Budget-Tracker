//
//  TouchView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 18.08.2022.
//

import UIKit


class TouchView:BasicView {
    var touchAction:((Bool)->())?
    var pressedAction:(()->())?
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if launch == nil {
            launch = self.backgroundColor
            self.createTouchView()
        }
    }
    
    var firstMovedSuperview = false
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !firstMovedSuperview {
            firstMovedSuperview = true
        }
    }
    
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        if firstMovedSuperview {
            touchAction = nil
            pressedAction = nil
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.moveTouchView(show: true, at: (touches.first, self))
        print("TouchViewtouchesBegan")
        super.touchesBegan(touches, with: event)
        if launch == nil {
            touchesBegun()
        } else {
            touchesBegun()
        }
        
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.moveTouchView(show: false)

        print("TouchViewtouchesEnded")
super.touchesEnded(touches, with: event)
        touchesEnded()
        if let action = pressedAction {
            action()
        }
    }
    
    
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        touchesEnded()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.moveTouchView(show: false)

        super.touchesCancelled(touches, with: event)
        touchesEnded()
        
    }
    override func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }
    var launch:UIColor?
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.moveTouchView(show: true, at: (touches.first, self))

        super.touchesMoved(touches, with: event)
        touchesEnded()
    }
    
    func touchesEnded() {
        print("etrfwdsacefr")
        
        if let touchAction = touchAction {
            touchAction(false)
        } else {
            defaultTouches(begun: false)
        }
    }
    
    func touchesBegun() {
        if let touchAction = touchAction {
            touchAction(true)
        } else {
            defaultTouches(begun: true)
        }
    }
    
    var pressedcolor:UIColor? = nil
    @IBInspectable open var pressColor: UIColor? = nil {
        didSet {
            if let color = pressColor {
                self.pressedcolor = color
            }
        }
    }
    
    private func defaultTouches(begun:Bool) {
        let darker = pressedcolor ?? (self.launch?.lighter() ?? .white)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.backgroundColor = begun ? darker : self.launch
        })
        
    }
    
    
    
    
}



