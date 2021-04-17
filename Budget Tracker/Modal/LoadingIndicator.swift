//
//  LoadingIndicator.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 16.04.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class LoadingIndicator {
    
    private let superView: UIView
    
    private let loadingMainView: UIView
    private let textLabel: UILabel
    private let loadingView: UIView
    private let ai: UIActivityIndicatorView
    
    init(superView: UIView) {
        self.superView = superView

        self.loadingMainView = UIView(frame: .zero)
        self.textLabel = UILabel(frame: .zero)
        self.loadingView = UIView(frame: .zero)
        self.ai = UIActivityIndicatorView.init(style: .whiteLarge)
        self.funccc = nil
    }

    private let loadingViewSize = (CGFloat(250), CGFloat(200))
    func showIndicator(text: String = "Wait") {
        
        let superFrame = self.superView.window?.frame ?? self.superView.frame
            self.loadingMainView.frame = CGRect(x: 0, y: 0, width: superFrame.width, height: superFrame.height)
        let loadingViewPosition = CGPoint(x: (superFrame.width / 2) - (loadingViewSize.0 / 2), y: (superFrame.height / 2) - (loadingViewSize.1 / 2))
        self.loadingView.frame = CGRect(x: loadingViewPosition.x, y: loadingViewPosition.y, width: loadingViewSize.0, height: loadingViewSize.1)
        self.loadingMainView.backgroundColor = normalBackgroundColor
        self.ai.color = .white
        self.ai.center = CGPoint(x: loadingViewSize.0 / 2, y: (loadingViewSize.1 / 4) + 30)
        self.loadingView.backgroundColor = UIColor(named: "darkTableColor")
        self.loadingView.layer.shadowColor = UIColor.black.cgColor
        self.loadingView.layer.shadowOpacity = 0.1
        self.loadingView.layer.shadowOffset = .zero
        self.loadingView.layer.shadowRadius = 6
        self.loadingView.layer.cornerRadius = 6
        self.textLabel.frame = CGRect(x: 5, y: (loadingViewSize.1 / 2) + 10, width: loadingViewSize.0 - 10, height: 90)
        self.textLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        self.textLabel.text = text
        self.textLabel.textColor = .white
        self.textLabel.adjustsFontSizeToFitWidth = false
        self.textLabel.numberOfLines = 0
        self.textLabel.textAlignment = .center
        self.loadingView.addSubview(self.textLabel)
        self.loadingView.addSubview(self.ai)
        self.loadingMainView.addSubview(self.loadingView)
        self.superView.window?.addSubview(self.loadingMainView)
        self.ai.startAnimating()
    }
    
    func showSmallIndicator() {
        let superFrame = self.superView.window?.frame ?? self.superView.frame
        self.loadingMainView.frame = CGRect(x: 0, y: 0, width: superFrame.width, height: superFrame.height)
        let loadingViewPosition = CGPoint(x: (superFrame.width / 2) - ((loadingViewSize.0 / 2) / 2), y: (superFrame.height / 2) - (loadingViewSize.0 / 2))
        self.loadingView.frame = CGRect(x: loadingViewPosition.x, y: loadingViewPosition.y, width: loadingViewSize.0 / 2, height: loadingViewSize.0 / 2)
        self.loadingMainView.backgroundColor = normalBackgroundColor
        self.ai.color = .white
        self.ai.center = CGPoint(x: loadingViewSize.0 / 4, y: loadingViewSize.0 / 4)
        self.loadingView.backgroundColor = .gray
        self.loadingView.layer.shadowColor = UIColor.black.cgColor
        self.loadingView.layer.shadowOpacity = 0.1
        self.loadingView.layer.shadowOffset = .zero
        self.loadingView.layer.shadowRadius = 6
        self.loadingView.layer.cornerRadius = 6
        self.textLabel.removeFromSuperview()
        self.textLabel.alpha = 0
        self.loadingView.addSubview(self.textLabel)
        self.loadingView.addSubview(self.ai)
        self.loadingMainView.addSubview(self.loadingView)
        self.superView.window?.addSubview(self.loadingMainView)
        self.textLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        self.textLabel.textAlignment = .center
        self.textLabel.textColor = .white
        self.ai.startAnimating()

    }
    
    func hideIndicator(force: Bool = false, completionText: String = "Done", hideAfter: TimeInterval = 0.0, completion: @escaping (Bool) -> ()) {
        self.textLabel.numberOfLines = 1
        if force {
            self.loadingMainView.removeFromSuperview()
            completion(true)
        } else {
            let superFrame = self.superView.window?.frame ?? self.superView.frame
            let loadingViewPosition = CGPoint(x: (superFrame.width / 2) - (loadingViewSize.0 / 2), y: (superFrame.height / 2) - (loadingViewSize.1 / 2))
            self.textLabel.text = completionText
            UIView.animate(withDuration: 0.15) {
                self.ai.alpha = 0
                self.loadingMainView.backgroundColor = .clear
            } completion: { (_) in
                let textFrameAnimation = self.textLabel.alpha == 0 ? false : true
                if !textFrameAnimation {
                    self.textLabel.frame = CGRect(x: 5, y: 0, width: self.loadingViewSize.0 - 10, height: self.loadingViewSize.1 / 4)
                }
                UIView.animate(withDuration: 0.33) {
                    if textFrameAnimation {
                        self.textLabel.frame = CGRect(x: 5, y: 0, width: self.loadingViewSize.0 - 10, height: self.loadingViewSize.1 / 4)
                    }
                    self.loadingView.frame = CGRect(x: loadingViewPosition.x, y: loadingViewPosition.y, width: self.loadingViewSize.0, height: self.loadingViewSize.1 / 4)
                    self.textLabel.alpha = 1
                } completion: { (_) in
                    self.ai.stopAnimating()
                    self.ai.removeFromSuperview()
                    Timer.scheduledTimer(withTimeInterval: hideAfter, repeats: false) { (_) in
                        UIView.animate(withDuration: 0.3) {
                            self.loadingMainView.frame = CGRect(x: 0, y: superFrame.height, width: superFrame.width, height: superFrame.height)
                        } completion: { (_) in
                            self.loadingMainView.removeFromSuperview()
                            completion(true)
                        }
                    }
                    
                }
            }
        }
    }
    
    func completeWithDone(title: String, error:Bool = false, description: String? = nil, completion: @escaping (Bool) -> ()) {
        let superFrame = self.superView.window?.frame ?? self.superView.frame
       // let descriptionLabel = UILabel(frame: CGRect(x: 5, y: (loadingViewSize.1 / 2) + 10, width: self.loadingViewSize.0 - 10, height: loadingViewSize.1))
        self.textLabel.text = title
        self.textLabel.textAlignment = .left
        let descriptionNotNill = description != nil ? true : false

        let doneView = UIView(frame: CGRect(x: 0, y: 200, width: self.loadingViewSize.0, height: 50))
        loadingView.layer.masksToBounds = true
        let doneLabel = UILabel(frame: CGRect(x: 10, y: descriptionNotNill ? 45 : 5, width: self.loadingViewSize.0 - 20, height: 35))
        doneLabel.textAlignment = .center
        doneLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        doneLabel.text = "OK"
        doneLabel.textColor = UIColor(named: "darkTableColor")
        doneLabel.backgroundColor = K.Colors.background
        doneLabel.layer.masksToBounds = true
        doneLabel.layer.cornerRadius = 6
        doneView.isUserInteractionEnabled = true
        doneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(donePressed(sender:))))
        doneView.addSubview(doneLabel)
        self.loadingView.addSubview(doneView)
        if descriptionNotNill {
            let descriptionLabel = UILabel(frame: CGRect(x: 10, y: 0, width: self.loadingViewSize.0 - 20, height: 35))
            descriptionLabel.numberOfLines = 0
         //   descriptionLabel.textAlignment = .center
            descriptionLabel.font = .systemFont(ofSize: 12, weight: .regular)
            descriptionLabel.textColor = K.Colors.background
            descriptionLabel.text = description
            doneView.addSubview(descriptionLabel)
        }
        let loadingViewPosition = CGPoint(x: (superFrame.width / 2) - (loadingViewSize.0 / 2), y: (superFrame.height / 2) - (loadingViewSize.1 / 2))

        
        UIView.animate(withDuration: 0.15) {
            self.ai.alpha = 0
        } completion: { (_) in
            UIView.animate(withDuration: 0.4) {
                self.loadingView.frame = CGRect(x: loadingViewPosition.x, y: loadingViewPosition.y, width: self.loadingViewSize.0, height: self.loadingViewSize.1 / 2 + (descriptionNotNill ? 30 : (-10)))
                self.textLabel.frame = CGRect(x: 10, y: 0, width: self.loadingViewSize.0 - 10, height: self.loadingViewSize.1 / 4)
                doneView.frame = CGRect(x: 0, y: 40, width: self.loadingViewSize.0, height: 100)
                
            } completion: { (_) in
                self.ai.stopAnimating()
                self.ai.removeFromSuperview()
                self.funccc = completion
                UIView.animate(withDuration: 0.4) {
                    if error {
                        
                    }
                    self.loadingMainView.backgroundColor = self.accentBackgroundColor
                }
            }
        }
    }

    var funccc: Any?
    
    @objc private func donePressed(sender: UITapGestureRecognizer) {
        if let function = funccc as? (Bool) -> () {
            fastHideIndicator(completion: function)
        }
        // fastHideIndicator(completion: funccc)
        
    }
    
    func fastHideIndicator(completion: @escaping (Bool) -> ()) {
        let superFrame = self.superView.window?.frame ?? self.superView.frame
        UIView.animate(withDuration: 0.15) {
            self.loadingMainView.backgroundColor = .clear
        } completion: { (_) in
            UIView.animate(withDuration: 0.3) {
                self.loadingMainView.frame = CGRect(x: 0, y: superFrame.height, width: superFrame.width, height: superFrame.height)
            } completion: { (_) in
                self.loadingMainView.removeFromSuperview()
                completion(true)
                //delegate!!!!!!!!!!
            }
        }
    }
    
    private var swipeToHide = false
    
    private let accentBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.55)
    private let normalBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.09)
}

