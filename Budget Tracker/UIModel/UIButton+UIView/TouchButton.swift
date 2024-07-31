//
//  TouchButton.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 05.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class TouchButton: Button {
    // for changing views animatable paramenetrs when Touch Begun (true) and ended (false)
    var touchAction:((Bool)->())?
    var pressedAction:(()->())?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if launch == nil {
            launch = linkBackground ? K.Colors.link : self.backgroundColor
            loadUI()
        }
    }

    var launch:UIColor?
        
    func touches(_ begun:Bool, completion:(()->())? = nil) {
        if let touchAction = touchAction {
            touchAction(begun)
            completion?()
        } else {
            defaultTouches(begun: begun, completion: completion)
        }
    }
    
    @IBInspectable open var pressColor: UIColor? = nil
    
    private func defaultTouches(begun:Bool, completion:(()->())? = nil) {
        let darker = pressColor ?? (self.launch?.lighter(componentDelta:0.2) ?? .white)

        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.backgroundColor = begun ? darker : self.launch
            self.layer.zoom(value: begun ? 1.2 : 1)
            self.titleLabel?.alpha = begun ? 0.5 : 1
            self.imageView?.alpha = begun ? 0.5 : 1
        }, completion: {
            if !$0 {
                return
            }
            completion?()
        })
        
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        moveTouchView(show: true, at:(touches.first, self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        moveTouchView(show: true, at:(touches.first, self))

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        moveTouchView(show: false)

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        moveTouchView(show: false)

    }
    
    
    
    private func loadUI() {
        addTarget(nil, action: #selector(buttonPressed(_:)), for: .touchDown)
        addTarget(nil, action: #selector(buttonRelised(_:)), for: .touchUpInside)
        addTarget(nil, action: #selector(buttonRelised(_:)), for: .touchCancel)
        addTarget(nil, action: #selector(buttonRelised(_:)), for: .touchUpOutside)
        addTarget(nil, action: #selector(buttonRelised(_:)), for: .touchDragOutside)
        addTarget(nil, action: #selector(buttonPressed(_:)), for: .touchDragInside)
        createTouchView()
    }


    
    @objc private func buttonPressed(_ button:UIButton) {
        print("fsfasadads")
        
        touches(true) {
         //   self.animatePress(false)
        }
    }
    
    @objc private func buttonRelised(_ button:UIButton) {

        touches(false) {
         //   self.animatePress(false)
        }
    }
    
    private var firstMovedSuperview = false
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
            launch = nil
            removeTouchView()
        }
    }
}
