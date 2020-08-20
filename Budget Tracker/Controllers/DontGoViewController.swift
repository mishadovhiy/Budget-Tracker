//
//  DontGoViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class DontGoViewController: UIViewController {
    
    @IBOutlet weak var sinOutButtonsStackView: UIStackView!
    @IBOutlet weak var saveDataButtonsStuckView: UIStackView!
    @IBOutlet weak var singOutTextStackView: UIStackView!
    @IBOutlet weak var saveDataStackView: UIStackView!
    @IBOutlet var actionButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        toggleScreen(.singOut)
        for i in 0..<actionButtons.count {
            actionButtons[i].layer.masksToBounds = true
            actionButtons[i].layer.cornerRadius = 4
        }
        
        
        
        
    }
    
    
    enum screenOptions {
        case singOut
        case saveData
    }
    
    func toggleScreen(_ screenOptions: screenOptions) {
        
        switch screenOptions {
        case .singOut:
            sinOutButtonsStackView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.sinOutButtonsStackView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                self.singOutTextStackView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            }
            UIView.animate(withDuration: 0.4) {
                self.saveDataButtonsStuckView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 300, 0)
                self.saveDataStackView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, UIScreen.main.bounds.width, 0, 0)
            }
            saveDataButtonsStuckView.isHidden = true
            
        case .saveData:
            saveDataButtonsStuckView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.saveDataButtonsStuckView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                self.saveDataStackView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            }
            UIView.animate(withDuration: 0.4) {
                self.sinOutButtonsStackView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 300, 0)
                self.singOutTextStackView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, UIScreen.main.bounds.width * (-1), 0, 0)
            }
            sinOutButtonsStackView.isHidden = true

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSingIn" {
            let vc = segue.destination as! LoginViewController
            vc.selectedScreen = .logIn
            print("fdg")
        }
    }
    
    @IBAction func actionPressed(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            print("yes")
            toggleScreen(.saveData)
        case 1:
            print("no")
            self.dismiss(animated: true, completion: nil)
        case 2:
            print("don't save")
            appData.username = ""
            appData.saveTransations([])
            appData.saveCategories([])
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toSingIn", sender: self)
            }
            
        case 3:
            print("save")
            appData.username = ""
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toSingIn", sender: self)
            }

        default:
            print("error")
            self.dismiss(animated: true, completion: nil)
        }
    }
    

}
