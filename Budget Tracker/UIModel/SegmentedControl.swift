//
//  SegmentedControl.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 19.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class SegmentedControl: UISegmentedControl {

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        let all = self.numberOfSegments
        for i in 0..<all {
            
            if let title = self.titleForSegment(at: i)?.localize {
                self.setTitle(title, forSegmentAt: i)
            }
        }
    }

}
