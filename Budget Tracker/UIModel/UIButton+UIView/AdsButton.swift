//
//  AdsButton.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class AdsButton: TouchButton {

    private var adLabel:UILabel?
    
    private var movedToWindow:Bool = false
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if !movedToWindow && adLabel == nil {
            movedToWindow = true
            DispatchQueue(label: "db", qos: .userInitiated).async {
                if !(AppDelegate.shared?.appData.proEnabeled ?? false) {
                    DispatchQueue.main.async {
                        self.createAdView()
                    }
                }
            }
        }
    }
    
    
    func toggleAdView(show:Bool) {
        if let label = adLabel {
            UIView.animate(withDuration: 0.3) {
                label.layer.opacity = show ? 1 : 0
            }
        }
    }
    
    private func createAdView() {
        adLabel = .init()
        adLabel?.isUserInteractionEnabled = false
        let text:NSMutableAttributedString = .init(attributedString: .init(string: "Watch\n", attributes: [
            .font:UIFont.systemFont(ofSize: 8, weight: .regular),
          //  .kern: Double(-2),
            .foregroundColor:UIColor.white
        ]))
        text.append(.init(string: "Ad", attributes: [
            .font:UIFont.systemFont(ofSize: 12, weight: .bold),
          //  .kern: Double(-2),
            .strokeWidth:2,
            .strokeColor:UIColor.red,
            .foregroundColor:UIColor.white
        ]))
        adLabel?.attributedText = text
        adLabel?.numberOfLines = 0
        adLabel?.backgroundColor = K.Colors.link
        adLabel?.layer.cornerRadius = 3
        adLabel?.layer.masksToBounds = true
        adLabel?.layer.shadow()
        adLabel?.textAlignment = .center
        addSubview(adLabel!)
        adLabel?.addConstaits([.right:-30, .top:0], superV: self)        
    }
    

}
