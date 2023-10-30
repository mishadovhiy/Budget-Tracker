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
    weak var pdfData:ManagerPDF?
    var appearedPdfData:ManagerPDF?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearedPdfData = pdfData
        updatePDF()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateNavButtons()
    }
    
    func updatePDF() {
        let atr:NSMutableAttributedString = .init(attributedString: pdfData?.pdfString(fromCreate: isEditing).0 ?? .init())
        attributeLabel.fadeTransition(0.3)
        attributeLabel.attributedText = atr
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        updateNavButtons()
        updatePDF()
    }
    
    func updateNavButtons() {
        var results:[UIBarButtonItem] = []
        if !isEditing {
            results.append(.init(title: "Edit", style: .done, target: nil, action: #selector(editingPressed)))
            results.append(.init(title: "Save", style: .done, target: nil, action: #selector(savePressed)))
            results.append(.init(title: "Export", style: .done, target: nil, action: #selector(exportPressed)))
            
        } else {
            results.append(.init(title: "done", style: .done, target: nil, action: #selector(doneEditingPressed)))
        }
        self.navigationController?.navigationItem.rightBarButtonItems = results
    }
    
    @objc func exportPressed() {
        pdfData?.exportPDF(sender: self.navigationController?.view ?? .init())
    }
    
    @objc func savePressed() {
        
    }
    
    @objc func doneEditingPressed() {
        setEditing(false, animated: true)
    }
    
    @objc func editingPressed() {
        setEditing(true, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let url = attributeLabel.linkPressed(at: touches) {
            pdfData?.additionalData.append(.init(custom: .init()))
            updatePDF()
            print(url, " ynhtbgrvfec")
        }
    }
}


extension AttributedStringTestVC {
    static func configure(pdf:ManagerPDF?) -> AttributedStringTestVC {
        let storyboard = UIStoryboard(name: "Reusable", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AttributedStringTestVC") as! AttributedStringTestVC
        vc.pdfData = pdf
        return vc
    }
}

