//
//  AlertController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 22.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class AlertControllerManager {
    var alert:AlertController!
    init() {
        self.alert = .init(title: "d", message: "d", preferredStyle: .alert)
        alert.addAction(.init(title: "some action", style: .default, handler: {action in
        //    action.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
          //      self.alert.dismiss(animated: true)
            })
        }))
        buttonInView(view: alert.view)
        
        present()
    }
    deinit {
        alert = nil
    }
    
    var buttonOne:UIButton?
    
    func buttonInView(view:UIView) {
        view.subviews.forEach({
            if let button = button(in: $0), buttonOne == nil {
                buttonOne = button
            } else if buttonOne == nil {
                if $0.subviews.count != 0 {
                    buttonInView(view: $0)
                } else {
                    errorFindingButton()
                }
            } else {
                completedButton()
            }
        })
    }
    
    func errorFindingButton() {
        print("errorFindingButton")

    }
    
    func completedButton() {
        print("completed button found")
        
        buttonOne?.layer.cornerRadius = 10
        buttonOne?.backgroundColor = UIColor.blue
        buttonOne?.setTitleColor(UIColor.white, for: .normal)
    }
    
    func button(in view:UIView) -> UIButton? {
        if let button = view as? UIButton {
            return button
        }
        return view.subviews.first(where: {
            $0 is UIButton
        }) as? UIButton
    }
    
    func present() {
        guard let vc = UIApplication.shared.keyWindow?.rootViewController as? NavigationController else {
            return
        }
       // let toVC = vc.presentedViewController ?? vc
        vc.present(alert, animated: true, completion: nil)
        
    }
    
}
class AlertController:UIAlertController {
    
    
 
    
}
