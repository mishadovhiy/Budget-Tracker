//
//  LoadingButton.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 02.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class LoadingButton: TouchButton {


    var refreshControl:UIActivityIndicatorView?
    private var launchColor:UIColor?
    private var launchTint:UIColor?
    
    var movedd = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if !movedd {
            movedd = true
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if launchColor == nil {
            launchColor = self.backgroundColor
        }
        if launchTint == nil {
            launchTint = self.tintColor
        }
    }
    override func removeFromSuperview() {
        super.removeFromSuperview()
        if movedd {
            refreshControl?.removeFromSuperview()
            refreshControl = nil
            launchColor = nil
            launchTint = nil
        }
    }
    
    private var firstMovedSuperview = false
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !firstMovedSuperview {
            firstMovedSuperview = true
        }
    }
    
    override func firstMovedToWindow() {
        super.firstMovedToWindow()
        if refreshControl == nil {
            refreshControl = .init(frame: .init(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            refreshControl?.backgroundColor = launchColor ?? K.Colors.link
            refreshControl?.tintColor = self.tintColor ?? .white
            refreshControl?.isHidden = !(refreshControl?.isAnimating ?? false)
          //  self.startAnimating()
            self.refreshControl?.layer.cornerRadius = 20
            //self.refreshControl.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.frame.height * (-1), 0)
            self.addSubview(refreshControl ?? UIView())
        }
    }

    
    var setAnimating:Bool {
        set {
            if (self.refreshControl?.isAnimating ?? false) != newValue {
                if newValue {
                    self.startAnimating()
                } else {
                    self.stopAnimating()
                }
            }
        }
        get {
            return self.refreshControl?.isAnimating ?? false
        }
    }
    
    func startAnimating(completion:(()->())? = nil) {
        isAnimating = true
        self.isHighlighted = false
        self.refreshControl?.startAnimating()
        self.refreshControl?.isHidden = false
        self.isUserInteractionEnabled = false
        //self.layer.transform = CATransform3DMakeScale(50, 50, 1)
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = .clear
            self.tintColor = .clear
            self.refreshControl?.frame = .init(x: self.frame.width / 2 - 20, y: self.frame.height / 2 - 20, width: 40, height: 40)
            //self.refreshControl.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
        } completion: { _ in
            if let c = completion {
                c()
            }
        }

    }
    var isAnimating:Bool = false
    func stopAnimating(completion:(()->())? = nil) {
      //  if self.refreshControl.isHidden != true {
        isAnimating = false
            self.isUserInteractionEnabled = true
        self.isHighlighted = false
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = self.launchColor ?? K.Colors.link
                self.tintColor = self.launchTint ?? .white
                self.refreshControl?.frame = .init(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                //self.refreshControl.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, self.frame.height * (-1), 0)
            } completion: { _ in
                self.refreshControl?.isHidden = true
                self.refreshControl?.stopAnimating()
                if let com = completion {
                    com()
                }
            }
     //   }
        
    }
    
    
}
