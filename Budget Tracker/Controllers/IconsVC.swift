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
    
    var iconsData:[IconsData] {
        get {
            let animals = IconsData(sectionName: "animals", data: [
                IconsData.Icon(name: "airplane.departure"),
                IconsData.Icon(name: "airplane"),
                IconsData.Icon(name: "alarm.fill"),
                IconsData.Icon(name: "align.horizontal.center.fill"),
                IconsData.Icon(name: "align.vertical.bottom.fill"),
                IconsData.Icon(name: "ant.fill"),
                IconsData.Icon(name: "atom"),
                IconsData.Icon(name: "bag.circle.fill"),
            ])
            let bank = IconsData(sectionName: "bank", data: [
                IconsData.Icon(name: "bag.fill"),
                IconsData.Icon(name: "bag"),
                IconsData.Icon(name: "bandage.fill"),
                IconsData.Icon(name: "banknote.fill"),
                IconsData.Icon(name: "battery.25"),
                IconsData.Icon(name: "battery.50"),
                IconsData.Icon(name: "battery.75"),
                IconsData.Icon(name: "battery.100"),
                IconsData.Icon(name: "bed.double.fill"),
                IconsData.Icon(name: "bell.badge.fill"),
                IconsData.Icon(name: "bell.badge"),
                IconsData.Icon(name: "bell.fill"),
                IconsData.Icon(name: "binoculars.fill"),
                IconsData.Icon(name: "bolt.horizontal.fill"),
                IconsData.Icon(name: "bolt.square.fill"),
                IconsData.Icon(name: "books.vertical.fill"),
            ])
            let briefcase = IconsData(sectionName: "briefcase", data: [
                IconsData.Icon(name: "briefcase.fill"),
                IconsData.Icon(name: "bubble.left.and.bubble.right.fill"),
                IconsData.Icon(name: "bubble.left.fill"),
                IconsData.Icon(name: "building.2.fill"),
                IconsData.Icon(name: "building.columns.circle.fill-1"),
                IconsData.Icon(name: "building.columns.circle.fill"),
                IconsData.Icon(name: "building.columns.fill"),
                IconsData.Icon(name: "burn"),
                IconsData.Icon(name: "bus.fill"),
                IconsData.Icon(name: "bus"),
                IconsData.Icon(name: "camera.fill"),
                IconsData.Icon(name: "camera.viewfinder"),
                IconsData.Icon(name: "candybarphone"),
                IconsData.Icon(name: "captions.bubble.fill"),
                IconsData.Icon(name: "car.fill"),
                IconsData.Icon(name: "cart.circle.fill"),
                
                IconsData.Icon(name: "cart.fill"),
                IconsData.Icon(name: "cart"),
                IconsData.Icon(name: "checkerboard.rectangle"),
                IconsData.Icon(name: "checkmark"),
                IconsData.Icon(name: "chevron.left.forwardslash.chevron.right"),
                IconsData.Icon(name: "chevron.up.circle"),
                IconsData.Icon(name: "clock.fill"),
                IconsData.Icon(name: "cloud.bolt.fill"),
                
                IconsData.Icon(name: "cloud.bolt.rain.fill"),
                IconsData.Icon(name: "cloud.rain.fill"),
                IconsData.Icon(name: "cloud.snow.fill"),
                IconsData.Icon(name: "comb.fill"),
                IconsData.Icon(name: "cpu.fill"),
                IconsData.Icon(name: "cpu"),
                IconsData.Icon(name: "creditcard.fill"),
                IconsData.Icon(name: "crown.fill")
            ])
            
            return [
                animals,
                bank,
                briefcase,
                bank,
                animals,
                bank,
                bank,
                bank,
                bank
                
            ]
        }
    }

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
    
  
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 10
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        title = "Set icon"
        
        collectionView.register(CollectionIconsHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderID)

    }
    

    struct IconsData {
        let sectionName: String
        let data:[Icon]

        struct Icon {
            let name: String
        }
    }
    
    let collectionHeaderID = "MyHeaderFooterClass"
}

extension IconsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return iconsData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let colorsSection = (screenType == .all || screenType == .colorsOnly) ? colors.count : 0
        let iconsSection = (screenType == .all || screenType == .iconsOnly) ? (section == 1 ? iconsData[section - 1].data.count : 0) : 0
        
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
            cell.mainImage.image = UIImage(named: data.name)
            
            let selectedColor = colorNamed(coloresStrTemporary[selectedColorId])
            cell.mainImage.tintColor = index == selectedIconIndex ? selectedColor :  K.Colors.balanceT
            
            return cell
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedColorId = indexPath.row
    
            delegate?.selected(img: selectedIconIndex == nil ? "" : iconsData[selectedIconIndex!.section].data[selectedIconIndex!.row].name, color: coloresStrTemporary[indexPath.row])
            collectionView.reloadData()
        } else {
            selectedIconIndex = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            collectionView.reloadData()
            delegate?.selected(img: iconsData[selectedIconIndex!.section].data[selectedIconIndex!.row].name, color: coloresStrTemporary[selectedColorId])
            
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


