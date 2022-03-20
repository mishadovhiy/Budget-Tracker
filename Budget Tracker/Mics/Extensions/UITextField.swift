//
//  UITextField.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 17.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UITextField {
    func setPaddings(_ amount:CGFloat){
        DispatchQueue.main.async {
            let leftView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.leftView = leftView
            self.leftViewMode = .always
            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.rightView = rightView
            self.rightViewMode = .always
        }
    }
    
    func setPlaceHolderColor(_ color:UIColor) {
        DispatchQueue.main.async {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: color])
        }
    }
    
    
}
