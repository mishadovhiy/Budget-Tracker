//
//  UICollectionViewDelegate_IconsVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 05.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

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
            
            cell.colorView.backgroundColor = .colorNamed(coloresStrTemporary[indexPath.row])
            //AppData.colorNamed(coloresStrTemporary[indexPath.row])
            let selectionColor = screenType == .colorsOnly ? K.Colors.sectionBackground : K.Colors.primaryBacground
            cell.backgroundColor = coloresStrTemporary[indexPath.row] == selectedColorName ? selectionColor : .clear
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconsVCCell", for: indexPath) as! IconsVCCell
            cell.layer.cornerRadius = 4
            let index = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            let iconName = iconsData[index.section].data[index.row]
            cell.mainImage.image = .init(iconName, errorName: "warning")
            let selectedColor = UIColor.colorNamed(selectedColorName)
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
