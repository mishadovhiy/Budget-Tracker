//
//  View.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 18.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

@IBDesignable
class View: UIView {

    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {
                self.layer.cornerRadius = self.cornerRadius
                self.layer.masksToBounds = self.cornerRadius > 0
            }
        }
    }

}
