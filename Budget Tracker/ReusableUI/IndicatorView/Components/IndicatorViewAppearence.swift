//
//  IndicatorViewAppearence.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 31.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit


extension IndicatorView {
    func setBacground(higlight:Bool, ai:Bool) {
        DispatchQueue.main.async {
            let higlighten = {
                UIView.animate(withDuration: 0.3) {
                    self.backgroundView.backgroundColor = ai ? self.normalBackgroundColor : self.accentBackgroundColor
                }
            }
            if higlight {
                UIView.animate(withDuration: 0.3) {
                    self.mainView.layer.shadowOpacity = 0.9
                    self.titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
                    self.backgroundView.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.8)
                } completion: { _ in
                    higlighten()
                }
            } else {
                higlighten()
            }
            
        }
    }
    
    func buttonStyle(_ button:UIButton, type:IndicatorView.button) {
        DispatchQueue.main.async {
            button.setTitleColor(self.buttonToColor(type.style), for: .normal)
            button.setTitle(type.title, for: .normal)
            if button.isHidden != false {
                button.isHidden = false
            }
            if button.superview?.isHidden != false {
                button.superview?.isHidden = false
            }
        }
    }
    
    private func buttonToColor(_ type:IndicatorView.ButtonType) -> UIColor {
        switch type {
        case .error: return .red
        case .link: return K.Colors.link
        case .regular: return K.Colors.category ?? .white
        }
    }
    
    func getAlertImage(image:Image?, type:ViewType) -> UIImage? {
        if let image = image {
            return .init(named: image.rawValue)
        } else {
            let needError = type == .error || type == .internetError
            return needError ? .init(named: Image.error.rawValue) : nil
        }
    }
    
}
