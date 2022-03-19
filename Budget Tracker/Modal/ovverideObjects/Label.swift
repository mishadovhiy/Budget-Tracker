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

    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.text = self.text?.localize
    }


}
