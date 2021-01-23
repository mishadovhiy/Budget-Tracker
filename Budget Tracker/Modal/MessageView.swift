//
//  Alerts.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class MessageView {
    
    let mainView: UIViewController

    var subview: UIView?
    var textLabel: UILabel?
    var closeButton: UIButton?
    
    enum MessageType {
        case error
        case succsess
        case staticError
        case internetError
    }
    @objc func closeButtonPressed(_ sender: Any) {
        hideMessage()
    }

    func hideMessage(duration: TimeInterval = 0.2) {
        stopTimers()
        
        DispatchQueue.main.async {
            self.closeButton?.alpha = 0
            UIView.animate(withDuration: duration) {
                self.subview?.frame = CGRect(x: 0, y: -80, width: 10, height: 30)
                self.textLabel?.alpha = 0
                self.textLabel?.textColor = K.Colors.background
                self.subview?.backgroundColor = K.Colors.category
            }
        }
        
    }
    
    
    var timers = [Timer]()
    func stopTimers() {
        for i in 0..<timers.count {
            timers[i].invalidate()
        }
    }
    
    func showMessage(text: String, type: MessageType, windowHeight: CGFloat = 50) {

        hideMessage(duration: 0)
        DispatchQueue.main.async {
            self.textLabel?.text = text
            self.subview?.frame = CGRect(x: 40, y: -80, width: self.mainView.view.bounds.width - 40, height: windowHeight)
            UIView.animate(withDuration: 0.4) {
                self.subview?.frame = CGRect(x: 20, y: self.mainView.view.safeAreaInsets.top + 5, width: self.mainView.view.bounds.width - 40, height: windowHeight)
                self.textLabel?.alpha = 1
            }
            UIView.animate(withDuration: 0.8) {
                self.closeButton?.alpha = 1
            }
            self.textLabel?.frame = CGRect(x: 5, y: 5, width: (self.subview?.frame.width ?? 0) - 5 - 30, height: windowHeight - 10)
            self.closeButton?.frame = CGRect(x: (self.subview?.frame.width ?? 0) - 30, y: 0, width: 30, height: windowHeight)
        }
        
        
        
        switch type {
        case .error:
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4) {
                    self.textLabel?.textColor = K.Colors.balanceV
                    self.subview?.backgroundColor = UIColor.red
                }
            }
            
            let timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false) { (action) in
                self.hideMessage()
            }
            timers.append(timer)
        case .succsess:
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4) {
                    self.textLabel?.textColor = K.Colors.balanceT
                    self.subview?.backgroundColor = K.Colors.pink
                  //  self.textLabel.backgroundColor = K.Colors.sectionBackground
                }
                let timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false) { (action) in
                    self.hideMessage()
                }
                self.timers.append(timer)
                UIView.animate(withDuration: 0.4) {
                    self.subview?.frame = CGRect(x: 20, y: (self.mainView.view.frame.height - self.mainView.view.safeAreaInsets.bottom) - (5 + windowHeight), width: self.mainView.view.bounds.width - 40, height: windowHeight)
                    self.textLabel?.frame = CGRect(x: 10, y: 5, width: (self.subview?.frame.width ?? 0) - 10 - 30, height: windowHeight - 10)
                }
            }
            
        case .internetError:
            print(appData.canShowInternetError)
            if !appData.canShowInternetError {
               // hideMessage(duration: 0)
                //comment all to else
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4) {
                        self.textLabel?.textColor = K.Colors.balanceV
                        self.subview?.backgroundColor = UIColor.yellow
                    }
                    
                }
                let timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { (action) in
                    self.hideMessage()
                }
                timers.append(timer)
                
            } else {
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4) {
                        self.textLabel?.textColor = K.Colors.balanceV
                        self.subview?.backgroundColor = UIColor.yellow
                    }
                }
                
                let timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { (action) in
                    self.hideMessage()
                }
                timers.append(timer)
            }
            
            
        case .staticError:
            UIView.animate(withDuration: 0.4) {
                self.textLabel?.textColor = K.Colors.balanceV
                self.subview?.backgroundColor = UIColor.red
            }
        }
        
    }
    
    func initMessage() {

        DispatchQueue.main.async {
            self.mainView.view.addSubview(self.subview ?? UIView())
            self.subview?.addSubview(self.closeButton ?? UIButton())
            self.subview?.addSubview(self.textLabel ?? UILabel())
            self.textLabel?.textAlignment = .left
            self.textLabel?.numberOfLines = 0
            self.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            self.textLabel?.alpha = 0
            self.subview?.layer.cornerRadius = 4
            self.subview?.layer.shadowColor = UIColor.black.cgColor
            self.subview?.layer.shadowOpacity = 0.3
            self.subview?.layer.shadowOffset = .zero
            self.subview?.layer.shadowRadius = 4
            self.closeButton?.alpha = 0
            self.closeButton?.setImage(UIImage(named: "cancel"), for: .normal)
            self.closeButton?.addTarget(self, action: #selector(self.closeButtonPressed(_:)), for: .allEvents)
        }
        
        print("message init")
    }
    /*
    func constraintAdd() {
        //subview
      //  let saveArTopHeight: CGFloat = 10
        //let verticalSubview = NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let topSubview = NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 5)
        let widthSubview = NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 280)
        let heightSubview = NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 100)
        let leftSubview = NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: UIApplication.shared.keyWindow, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
        
        let topLabel = NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let bottomLabel = NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let leftLabel = NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
        let rightLabel = NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 35)
        
        let bottomBtn = NSLayoutConstraint(item: closeButton ?? UIButton(), attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let widthBtn = NSLayoutConstraint(item: closeButton ?? UIButton(), attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 30)
        let topBtn = NSLayoutConstraint(item: closeButton ?? UIButton(), attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let rightBtn = NSLayoutConstraint(item: closeButton ?? UIButton(), attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
        subview.translatesAutoresizingMaskIntoConstraints = false
        mainView.view.addSubview(subview)
        mainView.view.addConstraints([topSubview, widthSubview, heightSubview, leftSubview])
        subview.addSubview(closeButton ?? UIButton())
        mainView.view.addConstraints([bottomBtn, widthBtn, topBtn, rightBtn])
        subview.addSubview(textLabel)
        mainView.view.addConstraints([topLabel, bottomLabel, leftLabel, rightLabel])
        
    }*/
    
    
    init(_ mainView: UIViewController) {

        self.mainView = mainView
        
        DispatchQueue.main.async {
            self.closeButton = UIButton()
            self.textLabel = UILabel()
            self.subview = UIView()
            
        }
        
        
        initMessage()
    }
    
}
