//
//  ClearTableCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 08.02.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class ClearCell:TableCell {
    override func draw(_ rect: CGRect) {
        setSelectedColor(.clear)
        super.draw(rect)
        
    
        createTouchView()
    }
    
    
    
    func setSelectionBackground(view:UIView, color:UIColor? = nil) {
        let selfColor = view.backgroundColor
        view.backgroundColor = selfColor
        self.touchesBegunAction = { begun in
            UIView.animate(withDuration: 0.3) {
                view.backgroundColor = begun ? (color ?? color?.lighter()) : selfColor
            }
        }
    }
    
    func setSelectionAlpha(view:UIView) {
        self.touchesBegunAction = { begun in
            UIView.animate(withDuration: 0.3) {
                view.alpha = begun ? 0.7 : 1
            }
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        touchesBegunAction = nil
    }
    
    var touchesBegunAction:((_ begun:Bool)->())?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveTouchView(show: true, at: (touches.first, self))
        super.touchesBegan(touches, with: event)
        guard let action = touchesBegunAction else { return }
        action(true)

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveTouchView(show:false)

        super.touchesEnded(touches, with: event)
        guard let action = touchesBegunAction else { return }
        action(false)

        self.reloadInputViews()
        self.layoutIfNeeded()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveTouchView(show:false)

        super.touchesCancelled(touches, with: event)
        guard let action = touchesBegunAction else { return }
        action(false)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveTouchView(show: true, at: (touches.first, self))

        super.touchesMoved(touches, with: event)

    }
}


class ClearCollectionCell:UICollectionViewCell {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setSelectedColor(.clear)
        createTouchView()
    }
    
    func setSelectionBackground(view:UIView, color:UIColor? = nil) {
        let selfColor = view.backgroundColor
        view.backgroundColor = selfColor
        self.touchesBegunAction = { begun in
            UIView.animate(withDuration: 0.3) {
                view.backgroundColor = begun ? (color ?? color?.lighter()) : selfColor
            }
        }
    }
    
    func setSelectionAlpha(view:UIView) {
        self.touchesBegunAction = { begun in
            UIView.animate(withDuration: 0.3) {
                view.alpha = begun ? 0.7 : 1
            }
        }
    }
    
    var touchesBegunAction:((_ begun:Bool)->())?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        moveTouchView(show: true, at: (touches.first, self))
        guard let action = touchesBegunAction else { return }
        action(true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let action = touchesBegunAction else { return }
        action(false)
        moveTouchView(show: false)

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard let action = touchesBegunAction else { return }
        action(false)
        moveTouchView(show: false)

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        moveTouchView(show: true, at: (touches.first, self))

    }
}
