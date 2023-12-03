//
//  TextField.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 01.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class TextField: UITextField {

    private var btnLine:CALayer?
    private var firstMoved:Bool = false
    var shouldReturn:(()->())? {
        didSet {
            let view = self.subviews.first(where: {$0 is DelegateView}) as? DelegateView
            view?.shouldReturn = self.shouldReturn
        }
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if !firstMoved {
            firstMoved = true
            btnLine = self.layer.drawSeparetor(color: .white)
            placeholder = super.placeholder
            backgroundColor = .clear
            layer.cornerRadius = 0
            let view = DelegateView()
            view.layer.name = "DelegateViewdd"
            self.addSubview(view)
            view.backgroundColor = .clear
            view.editing = self.editing(_:)
            self.delegate = view
            view.shouldReturn = shouldReturn
            createTouchView()
        }
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        moveTouchView(show: true, at:(touches.first, self))
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        moveTouchView(show: false)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        moveTouchView(show: true, at:(touches.first, self))
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        moveTouchView(show: false)
    }
    
    var _error:Bool = false
    var error:Bool {
        get {
            return _error
        }
        set {
            _error = newValue
        }
    }

    override var placeholder: String?{
        get { return super.placeholder }
        set {
            super.placeholder = newValue
            DispatchQueue.main.async {
                self.attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.balanceT ?? .red])//textFieldPlaceholder
            }

        }
    }
    
    private func editing(_ isEditing:Bool) {
      UIView.animate(withDuration: 0.23, animations: {
          let color = (isEditing ? K.Colors.link : K.Colors.balanceT) ?? .red
          self.btnLine?.backgroundColor = color.cgColor
          self.btnLine?.borderColor = color.cgColor
          (self.btnLine as! CAShapeLayer).strokeColor = color.cgColor
      })
    }
 
    class DelegateView:UIView, UITextFieldDelegate {
        var editing:((_ begun:Bool) -> ())?
        var shouldReturn:(()->())?
        func textFieldDidBeginEditing(_ textField: UITextField) {
          editing?(true)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
          editing?(false)
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            print("textFieldShouldReturntextFieldShouldReturn")
            self.shouldReturn?()
            return true
        }
    }
}
