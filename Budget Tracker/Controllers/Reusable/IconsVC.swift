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
    let icons = Icons()
    lazy var iconsData:[Icons.IconsData] = {
        if screenType == .colorsOnly {
            return []
        } else {
            return icons.icons
        }
    }()
    var closeAction:(()->())?
    static var shared:IconsVC?
    var selectedIconName = ""
    var selectedColorName = ""
    var defaultCategories:[NewCategories] = []
    var screenType:ScreenType = .all
    enum ScreenType {
        case all
        case iconsOnly
        case colorsOnly
        case defaultCategories
    }
    
    lazy var coloresStrTemporary:[String] = {
        return (screenType == .colorsOnly ? AppDelegate.shared?.appData.screenColors : AppDelegate.shared?.appData.categoryColors) ?? []
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

        IconsVC.shared = self
        collectionView.delegate = self
        collectionView.dataSource = self
        title = screenType == .colorsOnly ? "Primary color".localize : "Set icon".localize
        if closeAction != nil {
            closeButton.isHidden = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if -83 >= scrollView.contentOffset.y && closeAction != nil {
            closeAction?()
        }
        print(scrollView.contentOffset.y, " efrgetr")
    }
    
    let collectionHeaderID = "MyHeaderFooterClass"
    
}

extension IconsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if screenType == .defaultCategories {
            return 1
        } else {
            return iconsData.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if screenType == .defaultCategories {
            return defaultCategories.count
        } else {
            let colorsSection = coloresStrTemporary.count//(screenType == .all || screenType == .colorsOnly) ? colors.count : 0
            let iconsSection = section == 0 ? 0 : iconsData[section - 1].data.count//(screenType == .all || screenType == .iconsOnly) ? (section == 1 ? iconsData[section - 1].data.count : 0) : 0
            
            return section == 0 ? colorsSection : iconsSection
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: collectionHeaderID, for: indexPath) as! CollectionIconsHeader
            headerView.titleLabel?.text = indexPath.section == 0 ? "" : iconsData[indexPath.section - 1].sectionName
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView.init(frame: .zero)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? .init(width: 1, height: 1) : CGSize(width: collectionView.frame.width, height: 180.0)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if screenType == .defaultCategories {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconsCategoryCell", for: indexPath) as! IconsCategoryCell
            cell.set(category: defaultCategories[indexPath.row])
            return cell
        }
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconsVCColorCell", for: indexPath) as! IconsVCColorCell
            
            cell.colorView.backgroundColor = AppData.colorNamed(coloresStrTemporary[indexPath.row])
            let selectionColor = screenType == .colorsOnly ? K.Colors.sectionBackground : K.Colors.primaryBacground
            cell.backgroundColor = coloresStrTemporary[indexPath.row] == selectedColorName ? selectionColor : .clear
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconsVCCell", for: indexPath) as! IconsVCCell
            cell.layer.cornerRadius = 4
            let index = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            let iconName = iconsData[index.section].data[index.row]
           // cell.backgroundColor = index == selectedIconIndex ? K.Colors.secondaryBackground : .clear
            if #available(iOS 13.0, *) {
                cell.mainImage.image = AppData.iconSystemNamed(iconName, errorName: "warning")
            }
            
            let selectedColor = AppData.colorNamed(selectedColorName)
            //cell.mainImage.tintColor = index == selectedIconIndex ? selectedColor :  K.Colors.balanceT
            cell.mainImage.tintColor = iconName == selectedIconName ? selectedColor :  K.Colors.balanceT
            return cell
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if screenType == .defaultCategories {
            delegate?.categorySelected(defaultCategories[indexPath.row])
        } else if indexPath.section == 0 {
            selectedColorId = indexPath.row
    
            let imgName = selectedIconIndex == nil ? "" : iconsData[selectedIconIndex!.section].data[selectedIconIndex!.row]
            let colorName = coloresStrTemporary[indexPath.row]
            selectedColorName = colorName
            delegate?.selected(img: imgName, color: colorName)
            collectionView.reloadData()
        } else {
            selectedIconIndex = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            let imgName = iconsData[selectedIconIndex!.section].data[selectedIconIndex!.row]
           // let colorName = coloresStrTemporary[selectedColorId]
            print(imgName, " ihuyttfgvhbj")

            selectedIconName = imgName
            delegate?.selected(img: imgName, color: selectedColorName)
            collectionView.reloadData()
        }

    }
    
    

    /*func indexTitles(for collectionView: UICollectionView) -> [String]? {
        var result:[String] = ["Set Color"]
        let data = iconsData
        for i in 0..<data.count {
            result.append(data[i].sectionName)
        }
        return result
    }*/
    

}

class IconsVCCell:UICollectionViewCell {
    @IBOutlet weak var mainImage: UIImageView!
    
}

class IconsVCColorCell:UICollectionViewCell {
    
    
    @IBOutlet weak var colorView: UIView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 4
        colorView.layer.cornerRadius = colorView.layer.frame.width / 2
    }
    
}




class CollectionIconsHeader: UICollectionReusableView {
    var iniFrame = CGRect.zero
    override init(frame: CGRect) {
        iniFrame = frame
       super.init(frame: frame)
        
        titleLabel = UILabel(frame: CGRect(x: 10, y: frame.height - 25, width: frame.width - 20, height: 20))
        titleLabel?.textColor = .white
        titleLabel?.text = ""
        self.addSubview(titleLabel!)

    }

    
    var titleLabel: UILabel?
    
    var _text:String = ""
    var text:String {
        get {
            return _text
        }
        set {
            _text = newValue
            DispatchQueue.main.async {
                self.frame = newValue == "" ? CGRect(x: 0, y: 0, width: 1, height: 1) : self.iniFrame
                self.titleLabel?.text = newValue
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)

    }
}




class IconsCategoryCell:ClearCollectionCell {
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var catNameLabel: UILabel!
    func set(category:NewCategories) {
        catNameLabel.text = category.name
        catImageView.image = AppData.iconSystemNamed(category.icon)
            //.init(named: category.icon)
        catImageView.tintColor = AppData.colorNamed(category.color)
        touchesBegunAction = { begun in
            UIView.animate(withDuration: 0.15, delay: 0, options: .allowUserInteraction, animations: {
                self.catNameLabel.superview?.superview?.backgroundColor = begun ? K.Colors.link : K.Colors.darkSeparetor
            })
        }
    }
}
