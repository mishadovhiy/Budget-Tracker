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
    
    
    
    
    
}
