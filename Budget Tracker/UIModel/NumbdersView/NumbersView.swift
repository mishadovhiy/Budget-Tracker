//
//  NumbersView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 25.11.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreGraphics
import AVFoundation

protocol NumbersViewProtocol {
    func valuePressed(n:Int?, remove: NumbersView.SymbolType?)
}

class NumbersView: UIView {

    var _canCancel = true
    var canCancel:Bool {
        get {
            return _canCancel
        
        }
        set {
            _canCancel = newValue
            DispatchQueue.main.async {
                if self.cancelButton.isHidden != !newValue {
                    self.cancelButton.isHidden = !newValue
                }
            }
        }
    }
    var delegate:NumbersViewProtocol?
    
    var limit: Int?
    @IBOutlet private weak var mainView: UIView!
    override func removeFromSuperview() {
        super.removeFromSuperview()
        delegate = nil
    }
    var viewSize:CGSize {
        get {
            
            var frame:CGRect {
                var fr: CGRect?
                DispatchQueue.main.async {
                    fr = self.mainView.frame
                }
                return fr ?? self.mainView.frame
            }
            
            return CGSize(width: frame.width, height: frame.height)
        }
    }
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBAction private func numberPressed(_ sender: UIButton) {
        if let number = Int(sender.currentTitle ?? "") {
            DispatchQueue.main.async {
                AudioServicesPlaySystemSound(1104)
            }
            delegate?.valuePressed(n: number, remove: nil)
        }
    }
    
    @IBAction func symbolPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            DispatchQueue.main.async {
                AudioServicesPlaySystemSound(1155)
            }
            delegate?.valuePressed(n: nil, remove: .removeLast)
        case 1:
            DispatchQueue.main.async {
                AudioServicesPlaySystemSound(1155)
            }
            delegate?.valuePressed(n: nil, remove: .removeAll)
        
        default:
            break
        }
    }


    enum SymbolType {
        case removeLast
        case removeAll
    }

    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "Numbers", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NumbersView
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
