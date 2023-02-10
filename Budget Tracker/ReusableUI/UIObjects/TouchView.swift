//
//  TouchView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 18.08.2022.
//

import UIKit


class TouchView:View {
    var touchAction:((Bool)->())?
    var pressedAction:(()->())?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if launch == nil {
            launch = self.backgroundColor
            touchesBegun()
        } else {
            touchesBegun()
        }
        
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded()
        if let action = pressedAction {
            action()
        }
    }

    
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        touchesEnded()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded()
        
    }
    override func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }
    var launch:UIColor?
    
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
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = begun ? darker : self.launch
        }

    }
    

}

class TouchButton: Button {
    var touchAction:((Bool)->())?
    var pressedAction:(()->())?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if launch == nil {
            launch = self.backgroundColor
            touchesBegun()
        } else {
            touchesBegun()
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesEnded()
        
    }

    
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        super.touchesEstimatedPropertiesUpdated(touches)
        touchesEnded()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesEnded()
        
    }
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return super.resignFirstResponder()
    }
    var launch:UIColor?
    
    func touchesEnded() {
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

        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = begun ? darker : self.launch
        }

    }
}
