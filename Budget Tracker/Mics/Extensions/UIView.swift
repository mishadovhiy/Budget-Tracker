//
//  UIView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 28.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UIView {

    
    func shadow(opasity:Float = 0.6, black:Bool = false) {
        DispatchQueue.main.async {
            self.layer.shadowColor = !black ? K.Colors.secondaryBackground2.cgColor : UIColor.black.cgColor
            self.layer.shadowOffset = .zero
            self.layer.shadowRadius = 10
            self.layer.shadowOpacity = opasity
        }
    }
    
    func addBluer(frame:CGRect? = nil, style:UIBlurEffect.Style = (.init(rawValue: -1000) ?? .regular), insertAt:Int? = nil) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)//prominent//dark//regular
        let bluer = UIVisualEffectView(effect: blurEffect)
        //bluer.frame = frame ?? .init(x: 0, y: 0, width: frame?.width ?? self.frame.width, height: frame?.height ?? self.frame.height)
        // view.insertSubview(blurEffectView, at: 0)
        let vibracity = UIVisualEffectView(effect: blurEffect)
        // vibracity.contentView.addSubview()
        bluer.contentView.addSubview(vibracity)
        let constaints:[NSLayoutConstraint.Attribute : CGFloat] = [.leading:0, .top:0, .trailing:0, .bottom:0]
        vibracity.addConstaits(constaints, superV: bluer)
        if let at = insertAt {
            self.insertSubview(bluer, at: at)
        } else {
            self.addSubview(bluer)
        }
        
        bluer.addConstaits(constaints, superV: self)
        
        return bluer
    }
    func addConstaits(_ constants:[NSLayoutConstraint.Attribute:CGFloat], superV:UIView) {
        let layout = superV
        constants.forEach { (key, value) in
            let keyNil = key == .height || key == .width
            let item:Any? = keyNil ? nil : layout
            superV.addConstraint(.init(item: self, attribute: key, relatedBy: .equal, toItem: item, attribute: key, multiplier: 1, constant: value))
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}

extension CALayer {
    func shadow(opasity:Float = 0.6, offset:CGSize = .init(width: 0, height: 0), color:UIColor? = nil, radius:CGFloat = 10) {
        self.shadowColor = (color ?? .black).cgColor
        self.shadowOffset = offset
        self.shadowRadius = radius
        self.shadowOpacity = opasity
    }
}
