//
//  AttributedStringTestVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class AttributedStringTestVC:UIViewController {
    @IBOutlet weak var attributeLabel: UILabel!
    var string:NSAttributedString = .init(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAttachment()
    }
    
    func createAttachment() {
        
        let mutating:NSMutableAttributedString = .init(attributedString: string)
        
        let dataCount = 40
        for i in 0..<dataCount {
            let attachment = NSTextAttachment()
            attachment.image = createView("egrfe \(i)").toImage
            mutating.append(.init(attachment: attachment))
        }

        attributeLabel.attributedText = mutating

    }
    
    func createView(_ text:String) -> UIView {
        let view = UIView()
        let size:CGSize = .init(width: 650, height: 40)
        view.frame.size = size
        view.backgroundColor = .blue
        let label = UILabel(frame: .init(origin: .zero, size: size))
        label.text = text
        label.textAlignment = .left
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .black)
        view.addSubview(label)
        let separetor = 3
        for i in 0..<(Int(size.width) / separetor) {
            let dotWidth:CGFloat = 3
            let dott = UIView(frame: .init(x: ((CGFloat(separetor) + dotWidth) * CGFloat(i)), y: size.height - 1, width: dotWidth, height: 0.8))
            dott.backgroundColor = .white.withAlphaComponent(0.5)
            dott.layer.cornerRadius = 0.5
            view.addSubview(dott)
        }
        return view
    }
    

    
}

extension AttributedStringTestVC {
    static func configure(_ string:NSAttributedString) -> AttributedStringTestVC {
        let storyboard = UIStoryboard(name: "Reusable", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: "AttributedStringTestVC") as! AttributedStringTestVC
        vc.string = string
        return vc
    }
}

