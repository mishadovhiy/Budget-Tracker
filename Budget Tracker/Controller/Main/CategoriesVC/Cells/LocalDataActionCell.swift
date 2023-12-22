//
//  LocalDataActionCell.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 21.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

class NoCategoriesCell: UITableViewCell {
    
}

class LocalDataActionCell: UITableViewCell {
    
    @IBOutlet weak var deletePressed: UIView!
    @IBOutlet weak var sendPressed: UIView!
    @IBOutlet weak var saveLocallyView: UIView!
    
    @IBOutlet weak var deleteLabel: UILabel!
    
    var saveAction:(() -> ())?
    var sendAction:(() -> ())?
    var deleteAction:(() -> ())?
    
    func load() {
        let savePressed = UITapGestureRecognizer(target: self, action: #selector(saveLocallyPress(_:)))
        self.saveLocallyView.addGestureRecognizer(savePressed)
        
        let sendGesture = UITapGestureRecognizer(target: self, action: #selector(sendPress(_:)))
        self.sendPressed.addGestureRecognizer(sendGesture)
        
        let deleteGesture = UITapGestureRecognizer(target: self, action: #selector(deletePress(_:)))
        self.deletePressed.addGestureRecognizer(deleteGesture)
    }
    
    
    @objc func saveLocallyPress(_ sender: UITapGestureRecognizer) {
        AppDelegate.shared?.properties?.appData.needDownloadOnMainAppeare = true
        DispatchQueue.main.async {
            AppDelegate.shared?.properties?.ai.showLoading(title:"Saving".localize) {
                if let action = self.saveAction {
                    action()
                }
            }
        }
        
    }
    @objc func sendPress(_ sender: UITapGestureRecognizer) {
        AppDelegate.shared?.properties?.ai.showLoading(title:"Preparing".localize) {
            if let action = self.sendAction {
                action()
            }
        }
    }
    @objc func deletePress(_ sender: UITapGestureRecognizer) {
        AppDelegate.shared?.properties?.ai.showLoading(title:"Deleting".localize) {
            AppDelegate.shared?.properties?.appData.needDownloadOnMainAppeare = true
            if let action = self.deleteAction {
                action()
            }
        }
    }
    
}
