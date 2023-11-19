//
//  AttributedStringTestVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class PDFEditVC:SuperViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stopEditingButton: UIButton!
    var pdfData:ManagerPDF?
    @IBOutlet weak var exportPdfButton: AdButton!
    var appearedPdfData:ManagerPDF?
    var enteringValuePropHolder:PdfTextProperties?
    let containerConstraintKey = "egualHeightContainer"
    var tableData:[NSAttributedString] = []
    static let pdfLinkKey = "pdfLink"
    
    var selectingColorFor:SelectingColor = .background
    weak var settingsNav:UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        print(pdfData, " grefrwed")
        tableView.delegate = self
        tableView.dataSource = self
        appearedPdfData = pdfData
        pdfData?.pageWidth = AppDelegate.shared?.window?.frame.width ?? 10
        updatePDF()
        createSettingsContainer()
        print(containerView.frame.height, " erfwd")
        AppDelegate.shared?.banner.fullScreenDelegates.updateValue(self, forKey: self.restorationIdentifier!)
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 9
        self.stopEditingButton.isHidden = true

        let bannerH = AppDelegate.shared?.banner.size ?? 0
        self.tableView.contentInset.top = bannerH == 0 ? 0 : (bannerH + 15)
        self.tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
    }
    
    
    override func viewDidDismiss() {
        super.viewDidDismiss()
        AppDelegate.shared?.banner.fullScreenDelegates.removeValue(forKey: self.restorationIdentifier!)
        updateDB(completion: {
            self.pdfData = nil
            self.appearedPdfData = nil
        })
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateNavButtons()
        AppDelegate.shared?.banner.setBackground(clear: true)
        AppDelegate.shared?.banner.changeBannerPosition(top: true)


    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppDelegate.shared?.banner.setBackground(clear: false)
       // if !exportPressed {
            AppDelegate.shared?.banner.changeBannerPosition(top: false)
      //  }
    }
    
    override func firstAppeared() {
        super.firstAppeared()
        AppDelegate.shared?.banner.bannerCanShow(type: .pdf, completion: {
            self.exportPdfButton.toggleAdView(show: $0)
        })
    }
    

    
    
    var settingsData: [SelectValueVC.SelectValueSections] {
        var header: [SelectValueVC.SelectValueStruct] = []
        
        header.append(.init(name: "Default header", forProUsers: 4, switcher: .init(isOn: self.pdfData?.properties.defaultHeader ?? true, switched: {
            self.pdfData?.properties.defaultHeader = $0
            self.reloadTable()
            self.updateDB()
        })))
        
        header.append(.init(name: "Show date", switcher: .init(isOn: self.pdfData?.properties.needDate ?? true, switched: {
            self.pdfData?.properties.needDate = $0
            self.reloadTable()
            self.updateDB()
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
        
        colors.append(.init(name: "Default colors", regular: .init(description: pdfData?.properties.documentProperties.colors.secondary == nil ? "Default" : "", didSelect: {
            AppDelegate.shared?.ai.showAlert(buttons: (.init(title: "Cancel", style: .regular, close: true, action: nil), .init(title: "Yes", style: .error, action: { _ in
                self.pdfData?.properties.documentProperties.colors = .init(dict: [:])
                self.updatePDF()
                self.updateDB()
            })), title: "Are you sure you wanna set all colors to default?")
        })))
        
        
        var footers: [SelectValueVC.SelectValueStruct] = []
        
        footers.append(.init(name: "Default footer", forProUsers: 4, switcher: .init(isOn: self.pdfData?.properties.defaultFooter ?? false, switched: {
            self.pdfData?.properties.defaultFooter = $0
            self.reloadTable()
            self.updateDB()
        })))
        
        

        
        return [
            .init(sectionName: "", cells: header),
            .init(sectionName: "", cells: footers),
            .init(sectionName: "", cells: colors)
        ]
    }

    
    
    private func updateTableData() {
        let pdf = pdfData?.previewPDF()
        tableData.removeAll()
        pdf?.0.forEach({
            if $0.string != "\n" && $0.string != "\n\n\n" && $0.string != "  \n" {
                tableData.append($0)
            }
        })
    }
    
    private func updatePDF() {
        updateTableData()
        tableView.fadeTransition(0.3)
        tableView.reloadData()
        tableView.backgroundColor = UIColor(cgColor: pdfData?.properties.documentProperties.colors.background ?? UIColor.red.cgColor)
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

    
    //pressed
    
    @IBAction func stopEditingPressed(_ sender: Any) {
        self.stopEditingButton.fadeTransition(0.3)
        self.stopEditingButton.isHidden = true
        tableView.setEditing(false, animated: true)
        updatePDF()
        updateDB()
    }
    
    
    private func selectColorPressed(_ color: SelectingColor) {
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
    
    
    func addCustom(isFooter:Bool, str:String, insertAt:Int? = nil) {
        let holder = self.enteringValuePropHolder
        let newCustom = AdditionalPDFData.with({
            $0.custom = .with({
                $0.title = str
                $0.textSettins = holder ?? .init(dict: [:])
            })
        })
        print(isFooter, " isFooterisFooterisFooter")
        if isFooter {
            if let at = insertAt {
                self.pdfData?.properties.footers.insert(newCustom, at: at)
            } else {
                self.pdfData?.properties.footers.append(newCustom)
            }
            
        } else {
            
            if let at = insertAt {
                self.pdfData?.properties.headers.insert(newCustom, at: at)
            } else {
                self.pdfData?.properties.headers.append(newCustom)
            }
            
        }
        
    }
    
    func removeCustom(isFooter:Bool, at:Int) {
        let data = isFooter ? (self.pdfData?.properties.footers ?? []) : (self.pdfData?.properties.headers ?? [])
        if isFooter && ((data.count - 1) >= at) {
            self.pdfData?.properties.footers.remove(at: at)
        } else {
            self.pdfData?.properties.headers.remove(at: at)
        }
    }
    
    
    
    private func createSettingsContainer() {
        let vc = SelectValueVC.configure()
        vc.tableData = settingsData
        let nav = UINavigationController(rootViewController: vc)
        settingsNav = nav
        vc.titleText = "PDF Settings"
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

    private func settingsAppeared() {
        if !self.settingsApepareCalled {
            self.settingsApepareCalled = true
            self.updateDB()
        }
        
        self.toggleSettingsHeight(.none)
    }
    
    private var settingsApepareCalled = false
    
    func toEnterValue(_ title:String, selectionData:[SelectionStackView.SelectionData]?, selectedValue:AdditionalPDFData? = nil, nextPressed:@escaping(_ string:String)->()) {
        toggleSettingsHeight(.text)
        let vc = EnterValueVC.configure()
        vc.screenData = .init(taskName: title, title: "", placeHolder: "", nextAction: {
            nextPressed($0)
            self.settingsNav?.popViewController(animated: true)
            self.reloadTable()
            self.enteringValuePropHolder = .init(dict: [:])
            self.updateDB()
        }, screenType: .string)
        vc.selectionStackData = selectionData
        vc.nextButtonTitle = "Done"
        if let value = selectedValue {
            vc.textFieldValue = value.custom?.title
        }
//        vc.dismissedAction = {
//            self.toggleSettingsHeight(.none)
//        }
        self.settingsNav?.pushViewController(vc, animated: true)
    }
    
    
    func reloadTable() {
        self.updatePDF()
        let vcc = self.settingsNav?.viewControllers.first as! SelectValueVC
        vcc.tableData = self.settingsData
        vcc.tableView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        updateNavButtons()
        updatePDF()
    }
    
    func updateNavButtons() {
        
    }

    var exportPressed = false
    @IBAction func exportPdfPressed(_ sender: Any) {
        exportPressed = true
        pdfData?.pageWidth = pdfData?.normalPageWidth ?? 0
        pdfData?.exportPDF(sender: self.navigationController?.view ?? .init(), toEdit: false)

    }
    
    private func customSelected(data: AdditionalPDFData, type:LinkAttributeType, at:Int) {
        self.enteringValuePropHolder = data.custom?.textSettins ?? .init(dict: [:])
        print(enteringValuePropHolder, " enteringValuePropHolder")
        self.toEnterValue("Edit \(type.title)", selectionData: self.textCustomizationData, selectedValue: data) { string in
            self.removeCustom(isFooter: type == .footer, at: at)
            self.addCustom(isFooter: type == .footer, str: string, insertAt: at)
        }
    }
    
    
    func addCustomPressed(_ selectedValue:AdditionalPDFData? = nil, type:LinkAttributeType) {
        self.enteringValuePropHolder = selectedValue?.custom?.textSettins ?? .init(dict: [:])
        print(type, "addCustomPressed")
        self.toEnterValue("Enter new \(type.title)", selectionData: self.textCustomizationData, selectedValue: selectedValue, nextPressed: { string in
            self.addCustom(isFooter: type == .addFooter, str: string)
        })
    }
    
    func changePressed(atr:LinkAttributeType, components:[String]) {
        let pdf = self.pdfData?.properties ?? .init()
        let all = atr == .footer ? pdf.footers : pdf.headers
        if let index = atr.dataIndex(components: components), all.count - 1 >= index {
            self.customSelected(data: all[index], type: atr, at: index)
        } else {
            print("unksnow selected link")

        }
    }
    
    func linkPressed(_ url:URL) {
        let components = url.components
        print(components, " ferwdswerf")
        if let attribute = LinkAttributeType(rawValue: components.first(where: {
               LinkAttributeType(rawValue: $0) != nil
           }) ?? "")
        {
            switch attribute {
            case .footer, .header:
                changePressed(atr: attribute, components: components)
            case .addFooter, .addHeader:
                addCustomPressed(type: attribute)
            }
        }
    }
    
    func deletePressed(at:Int, isFooter:Bool) {
        self.removeCustom(isFooter: isFooter, at: at)
        self.updateTableData()
    }
    
    
    
    func toggleSettingsHeight(_ show:SettingsHeightType) {
        let constant = containerView.constraints.first(where: {$0.identifier == "settingsHeight"})
//        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0) {
//            constant?.constant = show.height
//            self.containerView.layoutIfNeeded()
//        }
        UIView.animate(withDuration: 0.45) {
            constant?.constant = show.height
            self.containerView.layoutIfNeeded()
        }
        
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
    
    
    private var textCustomizationData :[SelectionStackView.SelectionData] {
        let sel = enteringValuePropHolder
        print(sel?.textSize.rawValue, " rtegfwderf")
        return [
            .init(value: .init(name: "Color"), launchSelectedID: sel?.textColor?.rawValue, subValues: PdfTextColor.allCases.compactMap({
                .init(name: $0.rawValue.capitalized)
            }), subSelected: {
                self.enteringValuePropHolder?.textColor = .init(rawValue: $0.id ?? "") ?? .primary
                
            }),
            .init(value: .init(name: "Alighment"), launchSelectedID: sel?.alighment.rawValue, subValues: PdfTextProperties.TextAlighment.allCases.compactMap({
                .init(name: $0.rawValue.capitalized)
            }), subSelected: {
                self.enteringValuePropHolder?.alighment = .init(rawValue: $0.id ?? "") ?? .left
            }),
            .init(value: .init(name: "Size"), launchSelectedID: sel?.textSize.rawValue, subValues: PdfTextProperties.TextSize.allCases.compactMap({
                .init(name: $0.rawValue.capitalized)
            }), subSelected: {
                self.enteringValuePropHolder?.textSize = .init(rawValue: $0.id ?? "") ?? .small
            })
        ]
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
@available(iOS 14.0, *)
class ColorPickerVC: UIColorPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("egrfwed")
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
    }
}

extension PDFEditVC {

    static func configure(pdf:ManagerPDF) -> PDFEditVC {
        let storyboard = UIStoryboard(name: "Reusable", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AttributedStringTestVC") as! PDFEditVC
        vc.pdfData = pdf
        return vc
    }
}


