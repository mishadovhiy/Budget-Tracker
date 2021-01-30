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
        case internetError
    }
    @objc func closeButtonPressed(_ sender: Any) {
        hideMessage()
    }

    func hideMessage(duration: TimeInterval = 0.33) {
        stopTimers()
        if duration == 0 {
            DispatchQueue.main.async {
                self.closeButton?.alpha = 0
                let width = (self.mainView.view.bounds.width < 500 ? self.mainView.view.bounds.width : 500) - 40
                self.subview?.frame = CGRect(x: self.mainView.view.frame.width / 2 - width / 2, y: -80, width: width, height: 30)
                self.textLabel?.alpha = 0
                self.textLabel?.textColor = .black //K.Colors.background
                self.subview?.backgroundColor = .black //K.Colors.category
                self.subview?.alpha = 0
            }
        } else {
            DispatchQueue.main.async {
                self.closeButton?.alpha = 0
                let width = (self.mainView.view.bounds.width < 500 ? self.mainView.view.bounds.width : 500) - 40
                UIView.animate(withDuration: duration) {
                    self.subview?.frame = CGRect(x: self.mainView.view.frame.width / 2 - width / 2, y: -80, width: width, height: 30)
                    self.textLabel?.alpha = 0
                    self.textLabel?.textColor = .black
                    self.subview?.backgroundColor = .black
                } completion: { (_) in
                    self.subview?.alpha = 0
                }

            }
        }
        
    }
    
    
    private var timers = [Timer]()
    func stopTimers() {
        for i in 0..<timers.count {
            timers[i].invalidate()
        }
    }
    
    func showMessage(text: String, type: MessageType, windowHeight: CGFloat = 50, static: Bool = false) {
        let mainViewFrame = self.mainView.view.bounds
        let width = (mainViewFrame.width < 500 ? mainViewFrame.width : 500) - 30

        let x = mainViewFrame.width / 2 - width / 2


        hideMessage(duration: 0)
        DispatchQueue.main.async {
            self.subview?.alpha = 1
            self.textLabel?.text = text
            self.textLabel?.textAlignment = .left

            UIView.animate(withDuration: 0.4) {
                self.subview?.frame = CGRect(x: x, y: self.mainView.view.safeAreaInsets.top + 5, width: width, height: windowHeight)
                self.textLabel?.alpha = 1
            }
            UIView.animate(withDuration: 0.8) {
                self.closeButton?.alpha = 1
            }
            self.textLabel?.frame = CGRect(x: 12, y: 0, width: width - 6 - 30, height: windowHeight)
            self.closeButton?.frame = CGRect(x: (self.subview?.frame.width ?? 0) - 35, y: 0, width: 30, height: windowHeight)
            self.closeButton?.alpha = 1
        }
        
        
        
        switch type {
        case .error:
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4) {
                    self.textLabel?.textColor = .black
                    self.subview?.backgroundColor = UIColor(red: 224/255, green: 18/255, blue: 0/255, alpha: 0.90)
                }

            }

            let timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false) { (action) in
                self.hideMessage()
            }
            timers.append(timer)

        case .succsess:
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4) {
                    self.textLabel?.textColor = .black
                    self.subview?.backgroundColor = UIColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 0.9)//K.Colors.pink
                }
                let timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false) { (action) in
                    self.hideMessage()
                }
                self.timers.append(timer)
            }
            
        case .internetError:
            
            DispatchQueue.main.async {
                self.closeButton?.alpha = 0
                UIView.animate(withDuration: 0.4) {
                    self.textLabel?.textColor = .black
                    self.subview?.backgroundColor = UIColor(red: 224/255, green: 18/255, blue: 0/255, alpha: 0.90)
                }
                let superframe = self.mainView.view.frame
                UIView.animate(withDuration: 0.3) {
                    self.subview?.frame = CGRect(x: x, y: superframe.height - self.mainView.view.safeAreaInsets.bottom - windowHeight, width: width, height: windowHeight)
                    
                }
            }

            let timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false) { (action) in
                self.hideMessage()
            }
            timers.append(timer)
        }
        
        
        
    }
    
    private func initMessage() {

        DispatchQueue.main.async {
            self.mainView.view.addSubview(self.subview ?? UIView())
            self.subview?.addSubview(self.closeButton ?? UIButton())
            self.subview?.addSubview(self.textLabel ?? UILabel())
            self.textLabel?.textAlignment = .left
            self.textLabel?.numberOfLines = 0
            self.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            self.textLabel?.alpha = 0
            self.subview?.layer.cornerRadius = 6
            self.subview?.layer.shadowColor = UIColor.black.cgColor
            self.subview?.layer.shadowOpacity = 0.4
            self.subview?.layer.shadowOffset = .zero
            self.subview?.layer.shadowRadius = 6
            self.closeButton?.alpha = 0
            self.closeButton?.setImage(UIImage(named: "closeNoBack"), for: .normal)
            self.closeButton?.addTarget(self, action: #selector(self.closeButtonPressed(_:)), for: .allEvents)
            self.subview?.frame = .zero
            self.subview?.alpha = 0
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.closeSwipped(_:)))
            swipe.direction = .up
            self.subview?.addGestureRecognizer(swipe)

        }
        
        print("message init")
    }
    
    @objc func closeSwipped(_ sender: UISwipeGestureRecognizer) {
        hideMessage()

    }
    
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
