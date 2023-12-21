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

class CategoriesVC: SuperViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var refreshControl:UIRefreshControl?
    var hideTitle = false
    var fromSettings = false
    var delegate: CategoriesVCProtocol?
    var searchingText = ""
    var _allCategoriesHolder: [NewCategories] = []
    
    
    var transfaringCategories: LoginViewController.TransferingData?
    let selectionBacground = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
    weak static var shared:CategoriesVC?
    var _categories:[NewCategories] = []
    var _tableData:[ScreenDataStruct] = []
    var screenType: ScreenType = .categories
    @IBOutlet weak var iconsContainer: UIView!
    @IBOutlet weak var screenAI: UIActivityIndicatorView!
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
    var subvsLayed = false
    var appeareDidCall = false
    var unseenIDs:[String] = []
    var wasEdited = false
    @IBOutlet weak var moreNavButton: Button!
    var toSelectCategory = false
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "Category search".localize
        CategoriesVC.shared = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        selectingIconFor = (nil,nil)
        
        var strTitle:String {
            switch screenType {
            case .localData:
                return "Local data".localize
            case .categories:
                return "Categories".localize
            case .debts:
                return "Debts".localize
            }
        }
        title = strTitle
        
        updateUI()

        loadTableData()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        AppDelegate.shared?.properties?.banner.setBackground(clear: false)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if !subvsLayed {
            subvsLayed = true
            self.tableView.alpha = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        CategoriesVC.shared = self
        searchBar.endEditing(true)
            if let editTF = self.editingTF {
                self.editingTF = nil
                editTF.endEditing(true)
            }

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
//        UIApplication.shared.keyWindow?.backgroundColor = .clear
        AppDelegate.shared?.properties?.banner.setBackground(clear: true)
    }
    
    override func viewDidDismiss() {
        super.viewDidDismiss()
        refreshControl?.removeFromSuperview()
        refreshControl = nil
        editingTF = nil
        CategoriesVC.shared = nil
        historyDataStruct.removeAll()
        _categories.removeAll()
        _tableData.removeAll()
        removeKeyboardObthervers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !toHistory {
            if fromSettings {
                if !wasEdited {
                    delegate?.categorySelected(category: nil, fromDebts: false, amount: 0)
                } else {
                    delegate?.categorySelected(category: nil, fromDebts: false, amount: 0)
                }
            }
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -60.0 {
            hideAll()
            
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
            vc.allowEditing = screenType != .localData ? (selectedCategory?.purpose == .debt ? true : false) : false//(transfaringCategories == nil ? true : false)
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
                self.ai?.fastHide()
                if self.refreshControl?.isRefreshing ?? false {
                    self.refreshControl?.endRefreshing()
                }
                if self.tableView.alpha != 1 {
                    if self.screenAI?.isAnimating ?? false {
                        self.screenAI?.stopAnimating()
                    }
                    if self.screenAI?.isHidden != true {
                        self.screenAI?.isHidden = true
                    }
                    self.moreButton.isEnabled = true
                    UIView.animate(withDuration: 0.2) {
                        self.tableView.alpha = 1
                    }

                }
                
            }
        }
    }
}


extension CategoriesVC: IconsVCDelegate {
    func categorySelected(_ category: NewCategories) {
        print("dfsdafdbgvfcd")
        addCategoryPerform(section: category.purpose == .expense ? 0 : 1, category: .init(category: category, transactions: []))
    }
    
    func selected(img: String, color: String) {
        iconSelected(img: img, color: color)
    }

    func kayboardAppeared(_ keyboardHeight:CGFloat) {
        let height:CGFloat = keyboardHeight - (AppDelegate.shared?.properties?.appData.resultSafeArea.1 ?? 0) - self.defaultButtonInset
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

