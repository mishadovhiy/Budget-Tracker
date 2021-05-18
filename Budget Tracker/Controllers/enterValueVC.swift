//
//  enterValueVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 09.05.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

protocol enterValueVCProtocol {
    func hideScreen(close: Bool, value: String)
}

class enterValueVC: UIViewController {

    //if numbers - textfield - user interface enabled false, dont show keybpoard but show blue indicator
    //delegate
    
    var delegate: enterValueVCProtocol?
    
    enum screenType {
        case email
        case password
        case code
    }
    
    lazy var message: MessageView = {
        let message = MessageView(self)
        return message
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.hideScreen(close: true, value: "")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        } completion: { (_) in
            
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        } completion: { (_) in
            
        }
        
    }

    

}
