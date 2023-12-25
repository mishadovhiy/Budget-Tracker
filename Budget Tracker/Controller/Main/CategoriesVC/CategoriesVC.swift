//
//  CategoriesVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import AVFoundation

protocol CategoriesVCProtocol {
    func categorySelected(category: NewCategories?, fromDebts: Bool, amount: Int)
}

class CategoriesVC: SuperViewController {
    @IBOutlet weak var tableView: RefreshTableView!
    var hideTitle = false
    var fromSettings = false
    var delegate: CategoriesVCProtocol?
    var searchingText = ""
    var _allCategoriesHolder: [NewCategories] = []
    var transfaringCategories: LoginViewController.TransferingData?
    let selectionBacground = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
    var tableDataLoaded = false
    weak static var shared:CategoriesVC?
    var _categories:[NewCategories] = []
    var _tableData:[ScreenDataStruct] = []
    var screenType: ScreenType = .categories
    @IBOutlet weak var iconsContainer: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategory: NewCategories?
    let sectionsBeforeData = 2
    let regFooterHeight:CGFloat = 50
    weak var editingTF: UITextField?
    var _selectingIconFor:(IndexPath?, Int?)
    var prevSwowingIcons:IndexPath?
    let footerHeight:CGFloat = 40
    var toHistory = false
    let tableCorners:CGFloat = 15
    var screenDescription: String = ""
    var editingTfIndex: (Int?,Int?) = (nil,nil)
    var endAll = false
    var defaultButtonInset: CGFloat = 0
    var tableContentOf:UIEdgeInsets = UIEdgeInsets.zero
    var keyHeight: CGFloat = 0.0
    var showingIcons = true
    var appeareDidCall = false
    var unseenIDs:[String] = []
    var wasEdited = false
    @IBOutlet weak var moreNavButton: Button!
    var toSelectCategory = false
    var iconChildren:IconsVC? {
        return children.first(where: {$0 is IconsVC}) as? IconsVC
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        loadTableData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        AppDelegate.properties?.banner.setBackground(clear: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        CategoriesVC.shared = self
        stopEditing(keepIcons: true)
        if !appeareDidCall {
            toHistory = false
            appeareDidCall = true
        } else {
            loadTableData(loadFromUD: true)
            if toHistory {
                toHistory = false
            }
        }
        self.tableView.contentInset.bottom = self.defaultTableInset
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.properties?.banner.setBackground(clear: true)
    }
    
    override func viewDidDismiss() {
        super.viewDidDismiss()
        stopEditing()
        CategoriesVC.shared = nil
        historyDataStruct.removeAll()
        _categories.removeAll()
        _tableData.removeAll()
        removeKeyboardObthervers()
        children.forEach({$0.removeFromParent()})
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !toHistory && fromSettings {
            delegate?.categorySelected(category: nil, fromDebts: false, amount: 0)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -60.0 {
            stopEditing()
        }
    }
    
    lazy var viewTap:UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(pressedToDismiss(_:)))
    }()
    
    @IBAction func morePressed(_ sender: UIButton) {
        if screenType == .debts {
            showMoreVC()
        } else {
            showMoreOptions()
        }
    }
    
    func showMoreOptions() {
        MoreVC.presentMoreVC(currentVC: self, data: [
            .init(name: "Sort", description: "", showAI:false, action: showMoreVC),
            .init(name: "Default cetrgories", description: "", showAI:false, action: {
                self.toSelectCategory = true
                self.toggleIcons(show: true, animated: true, category: .create(dict: [:]))
            })
        ])
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toHistory":
            toHistory = true
            let vc = segue.destination as! HistoryVC
            vc.historyDataStruct = historyDataStruct
            vc.selectedCategory = selectedCategory
            vc.fromCategories = true
            vc.allowEditing = screenType != .localData ? (selectedCategory?.purpose == .debt ? true : false) : false
            vc.mainType = screenType != .localData ? .db : transfaringCategories == nil ? .localData : .unsaved
            vc.edited = {
                // self.loadTableData(loadFromUD: false)
            }
        case "selectIcon":
            let vc = segue.destination as! IconsVC
            vc.delegate = self
            vc.screenType = toSelectCategory ? .defaultCategories : .iconsOnly
            vc.closeAction = {
                self.toggleIcons(show: false, animated: true, category: nil)
            }
        default:
            break
        }
    }
    
    var allCategoriesHolder: [NewCategories] {
        get {
            return _allCategoriesHolder
        }
        set {
            _allCategoriesHolder = newValue
        }
    }
    
    var tableData:[ScreenDataStruct] {
        get {
            return _tableData
        }
        set {
            _tableData = newValue
            DispatchQueue.main.async {
                self.ai?.hide()
            }
        }
    }
}


extension CategoriesVC: IconsVCDelegate {
    func categorySelected(_ category: NewCategories) {
        addCategoryPerform(section: category.purpose == .expense ? 0 : 1, category: .init(category: category, transactions: []))
    }
    
    func selected(img: String, color: String) {
        iconSelected(img: img, color: color)
    }
    
    func kayboardAppeared(_ keyboardHeight:CGFloat) {
        let height:CGFloat = keyboardHeight - (AppDelegate.properties?.appData.resultSafeArea.1 ?? 0) - self.defaultButtonInset
        let cellEditing = (self.editingTF?.layer.name?.contains("cell") ?? false) || self.selectingIconFor.0 != nil
        self.tableView.contentInset.bottom = height + (cellEditing ? (self.regFooterHeight * (-1)) : 0)
    }
}

extension CategoriesVC {
    static func configure(type:ScreenType = .categories) -> CategoriesVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CategoriesVC") as! CategoriesVC
        vc.screenType = type
        return vc
    }
}

