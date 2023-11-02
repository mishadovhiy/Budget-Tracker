//
//  SwitchCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class SwitchCell: ClearCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var switcher: UISwitch!
    private var changedAction:((Bool)->())?
    
    func set(title:String, isOn:Bool, changed:@escaping(Bool)->()) {
        titleLabel.text = title
        changedAction = changed
        switcher.addTarget(self, action: #selector(switched(_:)), for: .valueChanged)
        
    }

    @objc private func switched(_ sender:UISwitch) {
        changedAction?(sender.isOn)
    }
    
}
