//
//  IconsVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 26.11.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit
import Foundation

protocol IconsVCDelegate {
    func selected(img:String, color:String)
    func categorySelected(_ category:NewCategories)
}


class IconsVC: SuperViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var delegate:IconsVCDelegate?
    @IBAction func closePressed(_ sender: Any) {
        closeAction?()
    }
    var icons:Icons! = Icons()
    lazy var iconsData:[Icons.IconsData] = {
        if screenType == .colorsOnly {
            return []
        } else {
            return icons.icons
        }
    }()
    var closeAction:(()->())?
    var selectedIconName = ""
    var selectedColorName = ""
    var defaultCategories:[NewCategories] = []
    var screenType:ScreenType = .all
    
    override func viewDidDismiss() {
        super.viewDidDismiss()
        icons = nil
        delegate = nil
    }
    
    lazy var coloresStrTemporary:[String] = {
        return (screenType == .colorsOnly ? AppDelegate.properties?.appData.screenColors : AppDelegate.properties?.appData.categoryColors) ?? []
    }()
    
    var selectedColorId:Int = 0
    var selectedIconIndex:IndexPath?
    
    let colorViewSize = 40
    
  
    var sbviesLoaded = false
    override func viewWillLayoutSubviews() {
        if !sbviesLoaded {
            sbviesLoaded = true
            collectionView.layer.cornerRadius = 10
            collectionView.register(CollectionIconsHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderID)
        }
        
    }
    
    func scrollToSelected() {
        let sections = Array(iconsData)
        for s in 0..<sections.count {
            let icons = sections[s].data
            for i in 0..<icons.count {
                if icons[i] == selectedIconName {
                   // DispatchQueue.main.async {
                        self.collectionView.scrollToItem(at: IndexPath(item: i, section: s + 1), at: .centeredVertically, animated: true)
                  //  }
                    return
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.backgroundColor = screenType == .colorsOnly ? K.Colors.primaryBacground : K.Colors.secondaryBackground
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        title = screenType == .colorsOnly ? "Primary color".localize : "Set icon".localize
        if closeAction != nil {
            closeButton.isHidden = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    

    
    enum ScreenType {
        case all
        case iconsOnly
        case colorsOnly
        case defaultCategories
    }
    let collectionHeaderID = "MyHeaderFooterClass"
    
}

extension IconsVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if -83 >= scrollView.contentOffset.y && closeAction != nil {
            closeAction?()
        }
        print(scrollView.contentOffset.y, " efrgetr")
    }
}
