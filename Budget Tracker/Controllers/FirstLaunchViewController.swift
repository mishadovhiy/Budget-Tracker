//
//  FirstLaunchViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 16.08.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class FirstLaunchViewController: UIViewController {

    
    //todo
    //after data loaded
    //check if user def != nil
    //ask user
    //seems like you have some saved data on your device would you like to replace it with data from database?
    //replace my data
    //upload my data on database
    //see what do i have
    
    //on this screen they see toggle
    //.on device
    // - table data = userdef
    //data from Database will stored on your device
    //.on database
    // - data = fromDB + userdef
    //replace my data
    //data from Database will stored on your device

    
    @IBOutlet var cornerButtons: [UIButton]!
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 9
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowRadius = 10
        contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 600, 0)
        for i in 0..<cornerButtons.count {
            cornerButtons[i].layer.masksToBounds = true
            cornerButtons[i].layer.cornerRadius = 6
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.6) {
            self.contentView.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLogIN" {
            let vc = segue.destination as! LoginViewController
            vc.selectedScreen = .logIn
        }
        if segue.identifier == "toCreate" {
            let vc = segue.destination as! LoginViewController
            vc.selectedScreen = .singIn
        }
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CreateAccPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toCreate", sender: self)
        }
    }
    
    @IBAction func singInPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toLogIN", sender: self)
        }
    }
}
