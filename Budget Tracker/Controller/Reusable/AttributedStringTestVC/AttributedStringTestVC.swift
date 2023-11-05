//
//  AttributedStringTestVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class AttributedStringTestVC:SuperViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var attributeLabel: UILabel!
    var pdfData:ManagerPDF?
    @IBOutlet weak var exportPdfButton: AdsButton!
    var appearedPdfData:ManagerPDF?
    var enteringValuePropHolder:PdfTextProperties?

    override func viewDidLoad() {
        super.viewDidLoad()
        print(pdfData, " grefrwed")
        appearedPdfData = pdfData
        updatePDF()
        createSettingsContainer()
        AppDelegate.shared?.banner.fullScreenDelegates.updateValue(self, forKey: self.restorationIdentifier!)

    }
    
    
    
    override func viewDidDismiss() {
        super.viewDidDismiss()
        AppDelegate.shared?.banner.fullScreenDelegates.removeValue(forKey: self.restorationIdentifier!)
        pdfData = nil
        appearedPdfData = nil

    }
    var firstAppeared = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateNavButtons()
        if !firstAppeared {
            firstAppeared = true
            AppDelegate.shared?.banner.bannerCanShow(type: .pdf, completion: {
                self.exportPdfButton.toggleAdView(show: $0)
            })
            
        }
    }
    
    func updatePDF() {
        let atr:NSMutableAttributedString = .init(attributedString: pdfData?.pdfString(fromCreate: false).0 ?? .init())
        attributeLabel.fadeTransition(0.3)
        attributeLabel.attributedText = atr
        attributeLabel.layer.backgroundColor = pdfData?.properties.colors.backgroundGet
    }
    
    weak var settingsNav:UINavigationController?
    
    private func selectionData() -> [SelectionStackView.SelectionData] {
        return [
            .init(value: .init(name: "Aligment"), subValues: [
                .init(name: "left"), .init(name: "right"), .init(name: "center")
            ], subSelected: {
                self.enteringValuePropHolder?.alighment = .init(rawValue: $0.name) ?? .left
                print(self.enteringValuePropHolder, "hgknjflmksdmjg")
            }),
            .init(value: .init(name: "Color"), subValues: [.init(name: "Primary"), .init(name: "Secondary")], subSelected: {
                self.enteringValuePropHolder?.textColor = $0.name
            })
        ]
    }
    
    

    
    func createPreferencesData() -> [SelectValueVC.SelectValueSections] {
        
        var header: [SelectValueVC.SelectValueStruct] = (self.pdfData?.additionalData.headers ?? []).compactMap({
            return .init(name: $0.custom?.title ?? "")
        })
        header.append(.init(name: "Remove header", switcher: .init(isOn: self.pdfData?.additionalData.defaultHeader ?? false, switched: {
            self.pdfData?.additionalData.defaultHeader = $0
            self.reloadTable()
        })))
        header.append(.init(name: "Background color", regular: .init(description: pdfData?.properties.colors.background == nil ? "Default" : "",didSelect: {
            if #available(iOS 14.0, *) {
                let colorVC = ColorPickerVC()
                colorVC.delegate = self
                self.selectingColorFor = .background
                self.settingsNav?.pushViewController(colorVC, animated: true)
            } else {
                self.newMessage?.show(title:"Not availible on your device OS version", type: .error)
            }
        })))
        header.append(.init(name: "Add header", regular: .init(didSelect: {
            self.toEnterValue("Enter new header", selectionData: self.selectionData(), nextPressed: {
                let holder = self.enteringValuePropHolder
                self.pdfData?.additionalData.headers.append(.init(custom: .init(title:$0, textSettins: holder ?? .init(dict: [:]))))

            })
        })))
        var footers: [SelectValueVC.SelectValueStruct] = (self.pdfData?.additionalData.footers ?? []).compactMap({
            return .init(name: $0.custom?.title ?? "")
        })
        footers.append(.init(name: "Remove footer", switcher: .init(isOn: self.pdfData?.additionalData.defaultFooter ?? false, switched: {
            self.pdfData?.additionalData.defaultFooter = $0
            self.reloadTable()
        })))
        footers.append(.init(name: "Add footer", regular: .init(didSelect: {
            self.toEnterValue("Enter new footer", selectionData: nil, nextPressed: {
                let holder = self.enteringValuePropHolder
                self.pdfData?.additionalData.footers.append(.init(custom: .init(title:$0, textSettins: holder ?? .init(dict: [:]))))
            })
        })))
        return [
            .init(sectionName: "Header", cells: header),
            .init(sectionName: "Transaction", cells: []),
            .init(sectionName: "Footer", cells: footers)
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

    
    func toEnterValue(_ title:String, selectionData:[SelectionStackView.SelectionData]?, nextPressed:@escaping(_ string:String)->()) {
        let vc = EnterValueVC.configure()
        vc.screenData = .init(taskName: "", title: title, placeHolder: "", nextAction: {
            nextPressed($0)
            self.settingsNav?.popViewController(animated: true)
            self.reloadTable()
            self.enteringValuePropHolder = nil
            //save to db
        }, screenType: .string)
        vc.selectionStackData = selectionData
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
        
    }

    @IBAction func exportPdfPressed(_ sender: Any) {
        pdfData!.exportPDF(sender: self.navigationController?.view ?? .init(), toEdit: false)

    }
    var selectingColorFor:SelectingColor = .background
}
@available(iOS 14.0, *)
class ColorPickerVC: UIColorPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("egrfwed")
    }
}

extension AttributedStringTestVC:UIColorPickerViewControllerDelegate {
    enum SelectingColor {
    case primary, secondary, background
    }
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        //save to db
    }
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        switch selectingColorFor {
        case .primary:
            pdfData?.properties.colors.primary = color.toHex
        case .secondary:
            pdfData?.properties.colors.secondary = color.toHex
        case .background:
            pdfData?.properties.colors.background = color.toHex
        }
        updatePDF()
    }
}


extension AttributedStringTestVC:FullScreenDelegate {
    func toggleAdView(_ show: Bool) {
        exportPdfButton.toggleAdView(show: show)
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

