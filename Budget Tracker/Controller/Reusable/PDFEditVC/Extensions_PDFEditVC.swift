//
//  Extensions_PDFEditVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 22.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension PDFEditVC {
    
    func selectColorPressed(_ color: SelectingColor) {
        if #available(iOS 14.0, *) {
            self.toggleSettingsHeight(.color)
            let colorVC = ColorPickerVC()
            colorVC.delegate = self
            self.selectingColorFor = color
            self.settingsNav?.pushViewController(colorVC, animated: true)
        } else {
            self.newMessage?.show(title:"Not availible on your device OS version", type: .error)
        }
    }
    
    func toSelectImg(selected:@escaping(_ newImg:Data?)->()) {
        let imgPicker = ImagePicker()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.dismissed = {
            AppDelegate.shared?.banner.appeare(force: true)
        }
        imageSelectedAction = selected
        AppDelegate.shared?.banner.hide(ios13Hide: true, completion: {
            self.present(imgPicker, animated: true)
        })
    }
    
    func toEnterValue(_ title:String, selectionData:[SelectionStackView.SelectionData]?, selectedValue:String? = nil, nextPressed:@escaping(_ string:String)->()) {
        toggleSettingsHeight(.text)
        let vc = EnterValueVC.configure()
        vc.screenData = .init(taskName: title, title: "", placeHolder: "", nextAction: {
            nextPressed($0)
            self.settingsNav?.popViewController(animated: true)
            if selectionData != nil {
                self.reloadTable()
                self.enteringValuePropHolder = .init(dict: [:])
                self.updateDB()
            }
        }, screenType: .string)
        vc.selectionStackData = selectionData
        vc.nextButtonTitle = "Done"
        if let value = selectedValue {
            vc.textFieldValue = value
        }
        self.settingsNav?.pushViewController(vc, animated: true)
        if selectionData != nil {
            let dateButton = UIBarButtonItem(title: "Date", style: .done, target: self, action: #selector(dateTypePressed(_:)))
            dateButton.tintColor = K.Colors.link
            vc.navigationItem.rightBarButtonItems?.append(dateButton)
            
            var artchButton:UIBarButtonItem!
            if #available(iOS 13.0, *) {
                artchButton = UIBarButtonItem(image:.init(systemName: "paperclip"), style: .done, target: self, action: #selector(addAttachmentPressed(_:)))
            } else {
                artchButton = UIBarButtonItem(title:"+", style: .done, target: self, action: #selector(addAttachmentPressed(_:)))
            }
            artchButton.tintColor = K.Colors.link
            vc.navigationItem.rightBarButtonItems?.append(artchButton)
        }
        

    }
    func toSelectValueVC(title:String, tableData:[SelectValueVC.SelectValueSections],
        complation:((_ vc:SelectValueVC)->())? = nil) {
        let vc = SelectValueVC.configure()
        vc.titleText = title
        vc.tableData = tableData
        settingsNav?.pushViewController(vc, animated: true)
        complation?(vc)
    }
    
    func createSettingsContainer() {
        let vc = SelectValueVC.configure()
        vc.tableData = settingsData
        let nav = UINavigationController(rootViewController: vc)
        settingsNav = nav
        vc.titleText = ""//"PDF Settings"
        addChild(nav)
        containerView.addSubview(nav.view)
        nav.view.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superV: containerView)
        nav.didMove(toParent: self)
        vc.appeareAction = {
            $0?.navigationController?.setNavigationBarHidden(true, animated: true)
            self.settingsAppeared()
        }
        vc.disapeareAction = {
            $0?.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    
    @objc func tableLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if #available(iOS 13.0, *) {
                self.vibrate(style: .soft)
            } else {
                self.vibrate(style: .light)
            }
            self.setEditing(true)
        }
        
    }
    
    func toggleSettingsHeight(_ show:SettingsHeightType) {
        let constant = containerView.constraints.first(where: {$0.identifier == "settingsHeight"})
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.45, animations: {
            constant?.constant = show.height
            self.containerView.layoutIfNeeded()
        }, completion: { _ in
            self.view.isUserInteractionEnabled = true
            if show == .none {
                self.tableView.reloadData()
            }
            if let row = self.selectedRow {
                self.tableView.scrollToRow(at: .init(row: row, section: 0), at: .bottom, animated: true)
            }
        })
    }
    enum SettingsHeightType {
        case none
        case color
        case text
        var height:CGFloat {
            switch self {
            case .none:
                return 125
            case .color:
                return 550
            case .text:
                return 300
            }
        }
    }
    
    enum LinkAttributeType:String {
        case header, footer, addHeader, addFooter
        
        var canReorder:Bool {
            switch self {
            case .header, .footer:
                return true
            default:
                return false
            }
        }
        
        var title:String {
            switch self {
            case .header, .addHeader:
                return "header"
            case .footer, .addFooter:
                return "footer"
            }
        }
        
        func dataIndex(components:[String]) -> Int? {
            return Int(components.first(where: {Int($0) != nil}) ?? "")
        }
    }
}


extension PDFEditVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       // settingsNav?.popViewController(animated: true)
        picker.dismiss(animated: true)
        guard let selectedAction = imageSelectedAction,
              let selected = (info[.editedImage] as? UIImage)?.pngData()
        else { return }
        
      //  AppDelegate.shared?.banner.appeare(force: true, completion: {
            selectedAction(selected)
     //   })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //settingsNav?.popViewController(animated: true)
        picker.dismiss(animated: true)
       // AppDelegate.shared?.banner.appeare(force: true)
    }
    
    
}


class ImagePicker:UIImagePickerController {
    var dismissed:(()->())?
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissed?()
        dismissed = nil
    }
}


extension PDFEditVC:UIColorPickerViewControllerDelegate {
    enum SelectingColor {
    case primary, secondary, background
    }
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        updateDB()
     //   toggleSettingsHeight(.none)
    }
    
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        switch selectingColorFor {
        case .primary:
            pdfData?.properties.documentProperties.colors.primary = color.cgColor
        case .secondary:
            pdfData?.properties.documentProperties.colors.secondary = color.cgColor
        case .background:
            pdfData?.properties.documentProperties.colors.background = color.cgColor
        }
        updatePDF()
    }
}

extension PDFEditVC:FullScreenDelegate {
    func toggleAdView(_ show: Bool) {
        exportPdfButton.toggleAdView(show: show)
        //here
    }
}
