//
//  UIViewController.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 20.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UIViewController {
    func shadow(for view:UIView, opasity: Float = 0.4, radius:CGFloat? = 9, color: UIColor = K.Colors.secondaryBackground) {
        DispatchQueue.main.async {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = opasity
            view.layer.shadowOffset = .zero
            view.layer.shadowRadius = 12
            if let radius = radius {
                view.layer.cornerRadius = radius
            }
            
            view.backgroundColor = color
        }
    }
    
    
    var previousViewController:UIViewController?{
        if let controllersOnNavStack = self.navigationController?.viewControllers{
            let n = controllersOnNavStack.count
            //if self is still on Navigation stack
            if controllersOnNavStack.last === self, n > 1{
                return controllersOnNavStack[n - 2]
            }else if n > 0{
                return controllersOnNavStack[n - 1]
            }
        }
        return nil
    }
    
    
}
