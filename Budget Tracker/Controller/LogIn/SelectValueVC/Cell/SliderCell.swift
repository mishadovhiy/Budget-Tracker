//
//  SliderCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 22.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class SliderCell: UITableViewCell {
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    var data:SelectValueVC.SelectValueStruct.SliderStruct?
    func set(_ data:SelectValueVC.SelectValueStruct.SliderStruct) {
        self.data = data
        sliderValueLabel.text = roundValue(data.resultValue).string()
        sliderView.value = data.value
        titleLabel.text = data.title
    }
    
    func roundValue(_ value:Float) -> Float {
        let n:Float = 1 / 0.5
        let res = value * n
        return res.rounded() / n
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        data?.value = sender.value
        sliderValueLabel.text = roundValue(data?.resultValue ?? 0).string()
        data?.changed(sender.value)
    }
}
