//
//  Label.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 19.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

@IBDesignable
class Label: UILabel {

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        self.text = self.text?.localize
    }
    
  /*  @IBInspectable open var textLocalized: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.text = self.textLocalized.localize
            }
        }
    }*/

}


