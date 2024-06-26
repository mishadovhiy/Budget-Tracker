//
//  SwitchCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class SwitchCell: ClearCell {
    @IBOutlet private weak var proView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var switcher: UISwitch!
    private var changedAction:((Bool)->())?
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
       // changedAction = nil
    }
    
    private var firstMovedSuperview = false
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !firstMovedSuperview {
            firstMovedSuperview = true
        }
    }
    
    func set(title:String, isOn:Bool, proEnabled:Bool = false, changed:@escaping(Bool)->()) {
        switcher.isUserInteractionEnabled = !proEnabled
        switcher.alpha = !proEnabled ? 1 : 0.5
        titleLabel.text = title
        changedAction = changed
        switcher.isOn = isOn
        switcher.addTarget(self, action: #selector(switched(_:)), for: .valueChanged)
        proView.isHidden = !proEnabled
    }

    @objc private func switched(_ sender:UISwitch) {
        changedAction?(sender.isOn)
    }
    
}
