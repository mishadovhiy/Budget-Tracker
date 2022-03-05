//
//  ColorView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 26.11.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class ColorView: UIView {
    
    
    @IBOutlet weak var colorView: UIView!
    
    var _selected:Bool = false
    var selected:Bool {
        get {
            return _selected
        }
        set {
            _selected = newValue
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.backgroundColor = newValue ? K.Colors.category : .clear
                } completion: { _ in
                    
                }

            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches)
    }
    
    func create(color: UIColor, selected: Bool) {
        self.selected = selected
        DispatchQueue.main.async {
            self.colorView.layer.cornerRadius = self.colorView.layer.frame.width / 2
            self.colorView.backgroundColor = color
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ColorView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ColorView
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
