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
        super.draw(rect)
        setSelectedColor(.clear)
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
        guard let action = touchesBegunAction else { return }
        action(true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let action = touchesBegunAction else { return }
        action(false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard let action = touchesBegunAction else { return }
        action(false)
    }

    
}


class ClearCollectionCell:UICollectionViewCell {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setSelectedColor(.clear)
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
        guard let action = touchesBegunAction else { return }
        action(true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let action = touchesBegunAction else { return }
        action(false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard let action = touchesBegunAction else { return }
        action(false)
    }

    
}
