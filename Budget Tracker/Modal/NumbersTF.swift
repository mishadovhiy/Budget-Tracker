//
//  NumbersTF.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 25.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class NumbersTF: UITextField {
    
    lazy var numberView: NumbersView = {
        let newView = NumbersView.instanceFromNib() as! NumbersView
        return newView
    }()
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print(#function)//not calling
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        print(#function)
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        print(#function)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        print(#function)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        print(#function)
        self.numberView.delegate = self
        self.numberView.frame = CGRect(x: 0, y: 0, width: 320, height: 320)
        //CGRect(x: (self.view.frame.width / 2) - (size.width / 2), y: self.view.frame.height - size.height, width: size.width, height: size.height)
     //   self.inputAccessoryView
        self.inputView = numberView
        self.reloadInputViews()
        
    }
    var _enteringValue:String = ""
    var enteringValue:String {
        get {
            return _enteringValue
        }
        set {
            _enteringValue = newValue
            DispatchQueue.main.async {
                self.text = newValue
            }
        }
    }
    
}

extension NumbersTF:NumbersViewProtocol {
    func valuePressed(n: Int?, remove: NumbersView.SymbolType?) {
        if let num = n {
            let enter = enteringValue + "\(num)"
            if let limit = numberView.limit {
                if enter.count <= limit {
                    enteringValue += "\(num)"
                }
            } else {
                enteringValue += "\(num)"
            }
            
            
        }
        if let sumbol = remove {
            switch sumbol {
            case .removeLast:
                if enteringValue.count > 0 {
                    enteringValue.removeLast()
                }
            case .removeAll:
                enteringValue = ""
            }
        }
    }
    
    
}
