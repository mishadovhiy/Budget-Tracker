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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("TouchViewtouchesBegan")
        if launch == nil {
            launch = self.backgroundColor
            touchesBegun()
        } else {
            touchesBegun()
        }
        
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("TouchViewtouchesEnded")

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
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.backgroundColor = begun ? darker : self.launch
        })
        
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
        
        /* UIView.animate(withDuration: 0.3) {
         self.backgroundColor = begun ? darker : self.launch
         }*/
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.backgroundColor = begun ? darker : self.launch
        })
        
        
    }
}


class TapAnimationView:UIView {
    func removeTapView() {
        guard let view = self.subviews.first(where: {$0.layer.name == "addTapView"}) else {
            return
        }
        view.removeWithAnimation()
    }
    
    func addTapView() {
        if let view = self.subviews.first(where: {$0.layer.name == "addTapView"}) {
            self.performAnimateTap(view: view, show: false, completion: {
                self.animateTap()
            })
        } else {
            let view = UIView()
            let w:CGFloat = 30
            view.isUserInteractionEnabled = false
            view.backgroundColor = .white
            view.alpha = 0.2
            view.layer.cornerRadius = w / 2
            view.layer.name = "addTapView"
            self.addSubview(view)
            view.addConstaits([.width:w, .height:w, .centerX:0, .centerY:0], superV: self)
            view.layer.shadow(color: .white)
            self.performAnimateTap(view: view, show: false, completion: {
                self.animateTap()
            })
        }
        
    }
    
    private func animateTap() {
        guard let view = self.subviews.first(where: {$0.layer.name == "addTapView"}) else {
            return
        }
        
        self.tapAnimationGroup(view: view) {
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { timer in
                self.animateTap()
            })
        }
    }
    
    private func tapAnimationGroup(view:UIView, completion:@escaping()->()) {
        performAnimateTap(view: view, show: true, completion: {
            self.performAnimateTap(view: view, completion: {
                
                
                self.performAnimateTap(view: view, show: true, delay: 0.05, completion: {
                    self.performAnimateTap(view: view, completion: {
                        completion()
                    })
                    
                })
                
                
                
            })
            
        })
        
    }
    
    private func performAnimateTap(view:UIView, show:Bool = false,delay:TimeInterval = 0, completion:@escaping()->()) {
        UIView.animate(withDuration: 0.65, delay: delay, options: .curveEaseInOut, animations: {
            view.alpha = show ? 0.2 : 0
        }, completion: { 
            if !$0 {
                return
            }
            completion()
        })
    }
}
