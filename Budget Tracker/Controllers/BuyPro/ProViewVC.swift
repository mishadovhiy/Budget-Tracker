//
//  ProViewVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class ProViewVC: SuperViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var mainDescriptionLabel: UILabel!
    @IBOutlet weak var mainTitleLabel: UILabel!
    var _data: BuyPageVC.PageStruct?
    var data: BuyPageVC.PageStruct {
        get {
            return _data ?? BuyPageVC.PageStruct(title: "-", description: "", imgName: "")
        }
        set {
            _data = newValue
         /*   DispatchQueue.main.async {
                if self.mainTitleLabel != nil {
                    self.mainTitleLabel.text = newValue.title
                    self.mainDescriptionLabel.text = newValue.description
                }
                
            }*/
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.mainTitleLabel.text = data.title
        self.mainDescriptionLabel.text = data.description
        self.mainImage.image = UIImage(named: data.imgName)
    }


}
