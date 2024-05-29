//
//  TapAnimationView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 05.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

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
