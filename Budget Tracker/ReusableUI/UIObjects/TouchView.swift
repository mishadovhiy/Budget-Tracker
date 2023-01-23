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
        touchesBegun()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded()
        if let action = pressedAction {
            action()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded()
    }
    override func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }
    lazy var launch:(UIColor) = {
        return (self.backgroundColor ?? .red)
    }()
    
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
        let darker = pressedcolor ?? self.launch.lighter()
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = begun ? darker : self.launch
        }

    }
    

}


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

class InfoView:TouchView {
    private var draweed = false
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !draweed {
            draweed = true
            
            self.touchAction = didPress(_:)
        }
    }
    
    private var _infoTitle: String? = nil
    @IBInspectable open var infoTitle: String? = nil {
        didSet {
            self._infoTitle = infoTitle
        }
    }
    private var _infoSubTitle: String? = nil
    @IBInspectable open var infoSubTitle: String? = nil {
        didSet {
            self._infoSubTitle = infoSubTitle
        }
    }
    
    private func didPress(_ begun:Bool) {
        if ((infoTitle ?? "") != "" || (infoSubTitle ?? "") != "") && !begun {
            AppDelegate.shared?.ai.showAlertWithOK(title: infoTitle?.localize, text: infoSubTitle?.localize, error: false, image: .init(named: "info"), okTitle: "Close".localize, hidePressed: nil)
        }
        UIView.animate(withDuration: 0.18) {
            self.alpha = begun ? 0.8 : 1
        }
    }
}
