//
//  OutlinedLabel.swift
//  Budget Tracker
//
//  Created by Mykhailo Dovhyi on 24.09.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import UIKit

class OutlinedLabel:UILabel {

        var outlineWidth: CGFloat = 1.0
    lazy var outlineColor: UIColor = (UIApplication.shared.sceneKeyWindow?.tintColor ?? .linkColor) ?? .red

        override func drawText(in rect: CGRect) {
            let strokeTextAttributes: [NSAttributedString.Key: Any] = [
                .strokeColor: outlineColor.withAlphaComponent(0.35),
                .strokeWidth: -outlineWidth,
                .foregroundColor:UIColor.clear
            ]
            
            let outlinedText = NSAttributedString(string: text ?? "", attributes: strokeTextAttributes)
            
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(outlineWidth)
            context?.setLineJoin(.round)
            context?.setTextDrawingMode(.stroke)
            
            outlinedText.draw(in: rect)
            super.drawText(in: rect)
        }
}
