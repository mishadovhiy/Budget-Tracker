//
//  AttributedStringTestVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class AttributedStringTestVC:UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var attributeLabel: UILabel!
    weak var pdfData:ManagerPDF?
    var appearedPdfData:ManagerPDF?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearedPdfData = pdfData
        updatePDF()
        createSettingsContainer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateNavButtons()
    }
    
    func updatePDF() {
        let atr:NSMutableAttributedString = .init(attributedString: pdfData?.pdfString(fromCreate: false).0 ?? .init())
        attributeLabel.fadeTransition(0.3)
        attributeLabel.attributedText = atr
    }
    
    weak var settingsNav:UINavigationController?
    
    
    
    func createPreferencesData() -> [SelectValueVC.SelectValueSections] {
        var header: [SelectValueVC.SelectValueStruct] = (self.pdfData?.additionalData ?? []).compactMap({
            .init(name: $0.custom?.title ?? "-")
        })
        header.append(.init(name: "Remove header", switcher: .init(isOn: false, switched: {
            if $0 {
                if !(self.pdfData?.additionalData.contains(where: {$0.custom != nil}) ?? false) {
                    self.pdfData?.additionalData.insert(.init(custom: .init()), at: 0)
                }
            } else {
                self.pdfData?.additionalData.removeAll(where: {$0.defaultHeader != nil})

            }
            self.reloadTable()
        })))
        header.append(.init(name: "Add header", regular: .init(didSelect: {
            self.toEnterValue("Enter new header")
        })))
        return [
            .init(sectionName: "Header", cells: header),
            .init(sectionName: "Transaction", cells: []),
            .init(sectionName: "Footer", cells: [])
        ]
    }
    
    func createSettingsContainer() {
        let vc = SelectValueVC.configure()
        vc.tableData = createPreferencesData()
        let nav = UINavigationController(rootViewController: vc)
        settingsNav = nav
        
        addChild(nav)
        containerView.addSubview(nav.view)
        nav.view.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superV: containerView)
        nav.didMove(toParent: self)

    }

    
    func toEnterValue(_ title:String) {
        let vc = EnterValueVC.configure()
        vc.screenData = .init(taskName: "", title: title, placeHolder: "", nextAction: {
            //get topVC tfHeight
            self.pdfData?.additionalData.append(.init(custom: .init(title:$0)))
            self.settingsNav?.popViewController(animated: true)
            self.reloadTable()
        }, screenType: .string)
        settingsNav?.pushViewController(vc, animated: true)
    }
    func reloadTable() {
        self.updatePDF()
        let vcc = self.settingsNav?.viewControllers.first as! SelectValueVC
        vcc.tableData = self.createPreferencesData()
        vcc.tableView.reloadData()
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

