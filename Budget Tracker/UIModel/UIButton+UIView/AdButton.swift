//
//  AdsButton.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class AdButton: TouchButton {

    private var adLabel:UILabel?
    
    private var movedToWindow:Bool = false
    
    private var firstMovedSuperview = false
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !firstMovedSuperview {
            firstMovedSuperview = true
        }
    }
    override func removeFromSuperview() {
        super.removeFromSuperview()
        if firstMovedSuperview {
            adLabel = nil
        }
        print("AdButtonAdButton removed removeFromSuperview")
    }
    
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
        if let label = adLabel, let background = self.subviews.first(where: {$0.layer.name == "adBack"}) {
            UIView.animate(withDuration: 0.3) {
                label.layer.opacity = show ? 1 : 0
                background.layer.opacity = show ? 1 : 0
            }
        }
    }
    
    private func createAdView() {
        adLabel = .init()
        adLabel?.isUserInteractionEnabled = false
        let text:NSMutableAttributedString = .init()
//        let text:NSMutableAttributedString = .init(attributedString: .init(string: "▶\n", attributes: [
//            .font:UIFont.systemFont(ofSize: 8, weight: .regular),
//            .foregroundColor:UIColor.white
//        ]))
        text.append(.init(string: "AD ", attributes: [
            .font:UIFont.systemFont(ofSize: 8, weight: .regular),
           // .strokeWidth:13,
           // .strokeColor:UIColor.white,
            .foregroundColor:UIColor.white
        ]))
        adLabel?.attributedText = text
        adLabel?.numberOfLines = 0
     //   adLabel?.backgroundColor = K.Colors.link
       // adLabel?.layer.cornerRadius = 3
       // adLabel?.layer.masksToBounds = true
        adLabel?.textAlignment = .center
        
        adLabel?.translatesAutoresizingMaskIntoConstraints = true
        adLabel?.frame = .init(origin: .init(x: -5, y: 7), size: .init(width: 30, height: 30))
        let background = UIImageView(image: .init(named: "adBack"))
        background.contentMode = .scaleAspectFit
        background.layer.name = "adBack"
        //background.backgroundColor = K.Colors.link
      //  background.layer.cornerRadius = 3
        self.addSubview(background)
        background.frame = .init(origin: .init(x: -5, y: -1), size: .init(width: 30, height: 45))
        background.layer.shadow(offset: .init(width: 5, height: 10))
        addSubview(adLabel!)
        //adLabel?.addConstaits([.right:-30, .top:0], superV: self)
    }
    

}
