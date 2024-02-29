//
//  CollectionIconsHeader.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 05.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class CollectionIconsHeader: UICollectionReusableView {
    var iniFrame = CGRect.zero
    override init(frame: CGRect) {
        iniFrame = frame
       super.init(frame: frame)
        
        titleLabel = UILabel(frame: CGRect(x: 10, y: frame.height - 25, width: frame.width - 20, height: 20))
        titleLabel?.textColor = .white
        titleLabel?.text = ""
        self.addSubview(titleLabel!)

    }

    
    var titleLabel: UILabel?
    
    var _text:String = ""
    var text:String {
        get {
            return _text
        }
        set {
            _text = newValue
            DispatchQueue.main.async {
                self.frame = newValue == "" ? CGRect(x: 0, y: 0, width: 1, height: 1) : self.iniFrame
                self.titleLabel?.text = newValue
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)

    }
}
