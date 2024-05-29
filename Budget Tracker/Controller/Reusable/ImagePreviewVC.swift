//
//  ImagePreviewVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 28.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class ImagePreviewVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imgData:Data?
    var selectedSet:Set<String> = [] {
        didSet {
            if !ignoreDataSet {
                delegate?.textSelected(Array(selectedSet))
            } else {
                ignoreDataSet = false
            }
        }
    }
    let textMLModel:DetectText = .init()
    var delegate:ImagePreviewProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = imgData {
            imageView.image = .init(data: data)
            textMLModel.recognize(img: imageView, vcView: self.view)

        }
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.select(touches, canRemove: true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        self.select(touches)
    }
    
    var ignoreDataSet:Bool = false
    func updateSelections(_ data:[String]? = nil) {
        if let value = data {
            ignoreDataSet = true
            self.selectedSet = Set(value)
        }
        view.subviews.forEach {
            if let layerName = $0.layer.name {
                let setContains = selectedSet.contains(layerName)
                $0.fadeTransition(0.1)
                $0.backgroundColor = (!setContains ? UIColor.red : .green).withAlphaComponent(DetectText.backgroundAlphaComp)
            }
            
        }
    }
    
    private func select(_ touches: Set<UITouch>, canRemove:Bool = false) {
        self.view.subviews.forEach {
            if $0.containsInRange(touches),
               $0.layer.name != nil
            {
                let setContains = selectedSet.contains($0.layer.name!)
                if setContains {
                    if canRemove {
                        selectedSet.remove($0.layer.name!)
                    }
                } else {
                    selectedSet.insert($0.layer.name!)
                }
                if !setContains || canRemove {
                    $0.fadeTransition(0.1)
                    $0.backgroundColor = (setContains ? UIColor.red : .green).withAlphaComponent(DetectText.backgroundAlphaComp)
                }
               
                print($0.layer.name, " rgterfwed")
            }
        }
    }
    
}

protocol ImagePreviewProtocol {
    func textSelected(_ all:[String])
}

@available(iOS 13.0, *)
extension ImagePreviewVC {
    static func configure(img:Data?, delegate:ImagePreviewProtocol?) -> ImagePreviewVC {
        let vc = UIStoryboard(name: "Reusable", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewVC") as! ImagePreviewVC
        vc.delegate = delegate
        vc.imgData = img
        return vc
    }
}
