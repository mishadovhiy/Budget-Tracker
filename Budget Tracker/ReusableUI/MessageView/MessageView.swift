//
//  MessageView.swift
//  Indicator&Message
//
//  Created by Mikhailo Dovhyi on 28.08.2021.
//

import UIKit
import AVFoundation

class MessageView: UIView {


    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet weak var mainImage: UIImageView!
    
    @IBAction func closePressed(_ sender: Any) {
        if !userCanClose {
            return
        }
        hideMessage()
    }
    
    
    override func draw(_ rect: CGRect) {
        //shadowRadius
        let swipeTop = UISwipeGestureRecognizer(target: self, action: #selector(closeSwipe(_:)))
        swipeTop.direction = .up
        self.mainView.addGestureRecognizer(swipeTop)
        self.translatesAutoresizingMaskIntoConstraints = true
    }

    @objc private func closeSwipe(_ sender: UISwipeGestureRecognizer) {
        if !userCanClose {
            return
        }
        hideMessage()
    }
    
    var messageData: (String, String?, viewType, UIImage?, TimeInterval?)?
    private var userCanClose = true
    var isShowing = false
    func show(title: String = "Success".localize, description: String? = nil, type:viewType, customImage: UIImage? = nil, autohide: TimeInterval? = 7.0) {

        
        if isShowing {
            let new = {
                self.show(title: title, description: description, type: type, customImage: customImage, autohide: autohide)
            }
            self.unshowedMessages.append(new)
            DispatchQueue.main.async {
                self.unseenCounterLabel.text = "\(self.unshowedMessages.count)"
            }

            if let old = messageData {
                if old.0 == title && old.1 == description && old.2 == type && old.3 == customImage && old.4 == autohide {
                    hideMessage()
                }
            }
            return
        } else {
            isShowing = true
            messageData = (title, description, type, customImage, autohide)
            let hideDescription = type == .internetError ? false : description ?? "" == ""
            let hideImage = type == .standart
       // AudioServicesPlaySystemSound(1007)
        DispatchQueue.main.async {
            let window = AppDelegate.shared?.window ?? UIWindow()
            //self.frame = window.frame
            window.addSubview(self)
            self.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: 100)
            let top = self.mainView.frame.maxY
            self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 500, 0)
            
            
            
            self.titleLabel.text = type == .internetError ? Text.Error.InternetTitle : title
            self.descriptionLabel.text = type == .internetError ? Text.Error.internetDescription : description
            if self.descriptionLabel.isHidden != hideDescription {
                self.descriptionLabel.isHidden = hideDescription
            }
            
            if self.mainImage.isHidden != hideImage {
                self.mainImage.isHidden = hideImage
            } 
            switch type {
            case .error, .internetError:
                self.mainImage.image = self.errorImage
            case .succsess:
                self.mainImage.image = self.succsessImage
            case .standart:
                self.mainImage.image = AppData.iconNamed("ic")
            }
            self.alpha = 1
            
            UIView.animate(withDuration: 0.25) {
                self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            } completion: { _ in
                
                if let hideTimer = autohide {
                    self.userCanClose = true
                    self.startTimer(secs: hideTimer)
                } else {
                    self.userCanClose = false
                }

            }

        }
        }
        
    }
    
    private var timer: Timer?
    private func startTimer(secs: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: secs, repeats: false) { tim in
            tim.invalidate()
            self.hideMessage()
        }
    }

    @IBOutlet weak var unseenCounterLabel: UILabel!
    
    func hideMessage(fast: Bool = false) {
        timer?.invalidate()
        if fast {
            isShowing = false
            DispatchQueue.main.async {
                self.removeFromSuperview()
            }
            
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.35) {
                    self.mainView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -500, 0)
                } completion: { _ in
                    self.isShowing = false
                    if let function = self.unshowedMessages.first as? () -> ()  {
                        self.unshowedMessages.removeFirst()
                        self.unseenCounterLabel.text = self.unshowedMessages.count == 0 ? "" : "\(self.unshowedMessages.count)"
                        function()
                    } else {
                        self.removeFromSuperview()
                    }
                    
                }

            }
        }
        
    }
    
    private var unshowedMessages: [Any] = []
    
    
    private var errorImage = UIImage(named: "warning")
    private var succsessImage = UIImage(named: "success")
    private var errorColor: UIColor = .red
    private var succsessColor: UIColor = .green
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "Message", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    enum viewType {
        case error
        case succsess
        case standart
        case internetError
    }
}
