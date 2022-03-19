//
//  SegmentedControl.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 19.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class SegmentedControl: UISegmentedControl {

    private var drawed = false
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !drawed {
            drawed = true
            let all = self.numberOfSegments
            for i in 0..<all {
                let title = self.titleForSegment(at: i)?.localize
                self.setTitle(title, forSegmentAt: i)
            }
        }
       
    }
    

}
