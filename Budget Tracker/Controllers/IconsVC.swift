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
}


class IconsVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var delegate:IconsVCDelegate?
    let icons = Icons()
    lazy var iconsData:[Icons.IconsData] = {
        if screenType == .colorsOnly {
            return []
        } else {
            return icons.icons
        }
    }()

    var screenType:ScreenType = .all
    enum ScreenType {
        case all
        case iconsOnly
        case colorsOnly
    }
    
    let colors:[UIColor] = [
        .yellow, .systemPink, .green, .orange, .red, .blue
    ]
    let coloresStrTemporary = [
        "yellowColor", "PinkColor", "GreenColor", "OrangeColor", "RedColor", "BlueColor"
    ]
    
    var selectedColorId:Int = 0
    var selectedIconIndex:IndexPath?
    
    let colorViewSize = 40
    
  
    var sbviesLoaded = false
    override func viewWillLayoutSubviews() {
        if !sbviesLoaded {
            sbviesLoaded = true
            collectionView.layer.cornerRadius = 10
          //  collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            title = "Set icon"
            
            collectionView.register(CollectionIconsHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderID)
            if screenType != .colorsOnly {
                self.view.backgroundColor = K.Colors.sectionBackground
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    

    
    
    let collectionHeaderID = "MyHeaderFooterClass"
}

extension IconsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return iconsData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let colorsSection = colors.count//(screenType == .all || screenType == .colorsOnly) ? colors.count : 0
        let iconsSection = section == 0 ? 0 : iconsData[section - 1].data.count//(screenType == .all || screenType == .iconsOnly) ? (section == 1 ? iconsData[section - 1].data.count : 0) : 0
        
        return section == 0 ? colorsSection : iconsSection
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: collectionHeaderID, for: indexPath) as! CollectionIconsHeader
            headerView.titleLabel?.text = indexPath.section == 0 ? "" : iconsData[indexPath.section - 1].sectionName
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 0 ? .init(width: 1, height: 1) : CGSize(width: collectionView.frame.width, height: 180.0)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconsVCColorCell", for: indexPath) as! IconsVCColorCell
            cell.layer.cornerRadius = 4
            cell.colorView.layer.cornerRadius = cell.colorView.layer.frame.width / 2
            cell.colorView.backgroundColor = colorNamed(coloresStrTemporary[indexPath.row])
            cell.backgroundColor = indexPath.row == selectedColorId ? K.Colors.secondaryBackground : .clear
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconsVCCell", for: indexPath) as! IconsVCCell
            cell.layer.cornerRadius = 4
            let index = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            let data = iconsData[index.section].data[index.row]
           // cell.backgroundColor = index == selectedIconIndex ? K.Colors.secondaryBackground : .clear
            cell.mainImage.image = UIImage(named: data)
            
            let selectedColor = colorNamed(coloresStrTemporary[selectedColorId])
            cell.mainImage.tintColor = index == selectedIconIndex ? selectedColor :  K.Colors.balanceT
            
            return cell
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedColorId = indexPath.row
    
            delegate?.selected(img: selectedIconIndex == nil ? "" : iconsData[selectedIconIndex!.section].data[selectedIconIndex!.row], color: coloresStrTemporary[indexPath.row])
            collectionView.reloadData()
        } else {
            selectedIconIndex = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            collectionView.reloadData()
            delegate?.selected(img: iconsData[selectedIconIndex!.section].data[selectedIconIndex!.row], color: coloresStrTemporary[selectedColorId])
            
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


