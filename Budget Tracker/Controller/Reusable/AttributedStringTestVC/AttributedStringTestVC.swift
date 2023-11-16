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
    let containerConstraintKey = "egualHeightContainer"
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
        updateDB(completion: {
            self.pdfData = nil
            self.appearedPdfData = nil
        })
        

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
        attributeLabel.layer.backgroundColor = pdfData?.properties.documentProperties.colors.background
    }
    
    weak var settingsNav:UINavigationController?
    
    private var selectionData :[SelectionStackView.SelectionData] {
        return [
            .init(value: .init(name: "Color"), subValues: PdfTextColor.allCases.compactMap({
                .init(name: $0.rawValue.capitalized)
            }), subSelected: {
                self.enteringValuePropHolder?.textColor = .init(rawValue: $0.id ?? "") ?? .primary
                
            }),
            .init(value: .init(name: "Alighment"), subValues: PdfTextProperties.TextAlighment.allCases.compactMap({
                .init(name: $0.rawValue.capitalized)
            }), subSelected: {
                self.enteringValuePropHolder?.alighment = .init(rawValue: $0.id ?? "") ?? .left
            }),
            .init(value: .init(name: "Size"), subValues: PdfTextProperties.TextSize.allCases.compactMap({
                .init(name: $0.rawValue.capitalized)
            }), subSelected: {
                self.enteringValuePropHolder?.textSize = .init(rawValue: $0.id ?? "") ?? .small
            })
        ]
    }
    
    func updateDB(completion:(()->())? = nil) {
        DispatchQueue(label: "db", qos: .userInitiated).async {
            AppDelegate.shared?.db.viewControllers.pdfProperties = self.pdfData?.properties ?? .init()
            print(AppDelegate.shared?.db.viewControllers.pdfProperties, " rtegrfwdf")
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

    
    private func selectColorPressed(_ color: SelectingColor) {
        if #available(iOS 14.0, *) {
            let colorVC = ColorPickerVC()
            colorVC.delegate = self
            self.selectingColorFor = color
            self.settingsNav?.pushViewController(colorVC, animated: true)
        } else {
            self.newMessage?.show(title:"Not availible on your device OS version", type: .error)
        }
    }
    
    private func addHeaderPressed(selectedValue:AdditionalPDFData? = nil) {
        self.enteringValuePropHolder = selectedValue?.custom?.textSettins ?? .init(dict: [:])
        self.toEnterValue("Enter new header", selectionData: self.selectionData, selectedValue: selectedValue, nextPressed: { string in
            self.addCustom(isFooter: false, str: string)
        })
    }
    
    private func addFooterPressed(selectedValue:AdditionalPDFData? = nil) {
        self.enteringValuePropHolder = selectedValue?.custom?.textSettins ?? .init(dict: [:])
        self.toEnterValue("Enter new footer", selectionData: nil, selectedValue: selectedValue, nextPressed: { string in
            self.addCustom(isFooter: true, str: string)
        })
    }
    
    func addCustom(isFooter:Bool, str:String) {
        let holder = self.enteringValuePropHolder
        self.pdfData?.properties.footers.append(.with({
            $0.custom = .with({
                $0.title = str
                $0.textSettins = holder ?? .init(dict: [:])
            })
        }))
    }
    
    func removeCustom(isFooter:Bool, at:Int) {
        if isFooter {
            if (self.pdfData?.properties.footers.count ?? 0) - 1 >= at {
                self.pdfData?.properties.footers.remove(at: at)
            }
        } else {
            if (self.pdfData?.properties.headers.count ?? 0) - 1 >= at {
                self.pdfData?.properties.headers.remove(at: at)

            }
        }
    }
    
    func createPreferencesData() -> [SelectValueVC.SelectValueSections] {
        var header: [SelectValueVC.SelectValueStruct] = []
        
        header.append(.init(name: "Default header", switcher: .init(isOn: self.pdfData?.properties.defaultHeader ?? true, switched: {
            self.pdfData?.properties.defaultHeader = $0
            self.reloadTable()
            self.updateDB()
        })))
        
        if let dataAll = pdfData?.properties.headers {
            for i in 0..<dataAll.count {
                let data = dataAll[i]
                header.append(.init(name: data.custom?.title ?? "", regular: .init(didSelect: {
                    self.toEnterValue("Edit header", selectionData: self.selectionData, selectedValue: data) { string in
                        self.removeCustom(isFooter: false, at: i)
                        self.addCustom(isFooter: false, str: string)
                    }
                })))
            }
        }
        
        
        header.append(.init(name: "Add header", regular: .init(didSelect: {
            self.addHeaderPressed()
        })))
        
        var colors: [SelectValueVC.SelectValueStruct] = []

        colors.append(.init(name: "Background color", regular: .init(description: pdfData?.properties.documentProperties.colors.background == nil ? "Default" : "", didSelect: {
            self.selectColorPressed(.background)
        })))
        colors.append(.init(name: "Primary text color", regular: .init(description: pdfData?.properties.documentProperties.colors.primary == nil ? "Default" : "", didSelect: {
            self.selectColorPressed(.primary)
        })))
        colors.append(.init(name: "Secondary text color", regular: .init(description: pdfData?.properties.documentProperties.colors.secondary == nil ? "Default" : "", didSelect: {
            self.selectColorPressed(.secondary)
        })))
        
        var footers: [SelectValueVC.SelectValueStruct] = []
        
        footers.append(.init(name: "Default footer", switcher: .init(isOn: self.pdfData?.properties.defaultFooter ?? false, switched: {
            self.pdfData?.properties.defaultFooter = $0
            self.reloadTable()
            self.updateDB()
        })))
        
        if let dataAll = pdfData?.properties.footers {
            for i in 0..<dataAll.count {
                let data = dataAll[i]
                footers.append(.init(name: data.custom?.title ?? "", regular: .init(didSelect: {
                    self.toEnterValue("Edit footer", selectionData: self.selectionData, selectedValue: data) { string in
                        self.removeCustom(isFooter: true, at: i)
                        self.addCustom(isFooter: true, str: string)
                    }
                })))
            }
        }
        
        
        footers.append(.init(name: "Add footer", regular: .init(didSelect: {
            self.addFooterPressed()
        })))
        return [
            .init(sectionName: "Header", cells: header),
           // .init(sectionName: "Transaction", cells: []),
            .init(sectionName: "Footer", cells: footers),
            .init(sectionName: "Document colors", cells: colors)
        ]
    }
    
    func createSettingsContainer() {
        let vc = SelectValueVC.configure()
        vc.tableData = createPreferencesData()
        let nav = UINavigationController(rootViewController: vc)
        settingsNav = nav
        vc.titleText = "PDF Settings"
        addChild(nav)
        containerView.addSubview(nav.view)
        nav.view.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superV: containerView)
        nav.didMove(toParent: self)

    }

    private func toggleContainerHeight(_ show:Bool, completion:(()->())? = nil) {
        guard let constraint = self.view.constraints.first(where: {$0.identifier == containerConstraintKey}),
              let contantShow = self.view.constraints.first(where: {$0.identifier == "containerConstraintKeyShow"})
        else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
           // constraint.priority = show ? .defaultLow : .defaultHigh
            constraint.isActive = show ? false : true
            contantShow.priority = show ? .defaultHigh : .defaultLow
            contantShow.isActive = show ? true : false
            self.view.layoutIfNeeded()
            self.containerView.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })

    }
    
    func toEnterValue(_ title:String, selectionData:[SelectionStackView.SelectionData]?, selectedValue:AdditionalPDFData? = nil, nextPressed:@escaping(_ string:String)->()) {
        let vc = EnterValueVC.configure()
        vc.screenData = .init(taskName: "", title: title, placeHolder: "", nextAction: {
            nextPressed($0)
            self.settingsNav?.popViewController(animated: true)
            self.reloadTable()
            self.enteringValuePropHolder = nil
            self.updateDB()
        }, screenType: .string)
        vc.selectionStackData = selectionData
        if let value = selectedValue {
            vc.textFieldValue = value.custom?.title
        }
        self.settingsNav?.pushViewController(vc, animated: true)
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
            pdfData?.properties.documentProperties.colors.primary = color.cgColor
        case .secondary:
            pdfData?.properties.documentProperties.colors.secondary = color.cgColor
        case .background:
            pdfData?.properties.documentProperties.colors.background = color.cgColor
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

    static func configure(pdf:ManagerPDF) -> AttributedStringTestVC {
        let storyboard = UIStoryboard(name: "Reusable", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AttributedStringTestVC") as! AttributedStringTestVC
        vc.pdfData = pdf
        return vc
    }
}


