//
//  TableViewExtension.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 02.04.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension CategoriesVC {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count + 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return screenDescription == "" ? 0 : 1
        } else {
            if section == 1 {
                return screenType == .localData ? 1 : 0
            } else {
                return tableData[section - sectionsBeforeData].data.count == 0 ? 1 : tableData[section - 2].data.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 || section == 1 {
            return nil
        } else {
            return tableData[section - sectionsBeforeData].title
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return UITableViewCell()
        } else {
            if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LocalDataActionCell", for: indexPath) as! LocalDataActionCell
                
                cell.load()
                let hideDownload = transfaringCategories == nil ? true : false
                
                if cell.sendPressed.isHidden != !hideDownload {
                    cell.sendPressed.isHidden = !hideDownload
                }
                if cell.deletePressed.isHidden != !hideDownload {
                    cell.deletePressed.isHidden = !hideDownload
                }
                
                if cell.saveLocallyView.isHidden != hideDownload {
                    cell.saveLocallyView.isHidden = hideDownload
                }

                let deleteAction = {
                    appData.needDownloadOnMainAppeare = true
                    self.db.localCategories = []
                    self.db.localTransactions = []
                //    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                  //  }
                }
                let sendAll = {
                    appData.needDownloadOnMainAppeare = true
                    appData.sendSavedData = true
                        self.navigationController?.popToRootViewController(animated: true)
                }
                
                
                cell.saveAction = saveToLocal
                cell.deleteAction = deleteAction
                cell.sendAction = sendAll
                return cell
            } else {
                
                if tableData[indexPath.section - sectionsBeforeData].data.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NoCategoriesCell", for: indexPath) as! NoCategoriesCell
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent, for: indexPath) as! categoriesVCcell
                    
                    let index = IndexPath(row: indexPath.row, section: indexPath.section - sectionsBeforeData)
                    cell.lo(index: index, footer: nil)

                    let category = tableData[index.section].data[indexPath.row]

                    let hideUnseenIndicator = containsINUnseen(id: "\(category.category.id)") ? false : true
                    cell.unseenIndicatorView.isHidden = hideUnseenIndicator

                    let hideEditing = category.editing != nil ? false : true
                    let hideQnt = !hideEditing
                    let hideTitle = !hideEditing
                    let hidedueDate = !hideEditing ? true : (category.category.dueDate == nil)
                    
                    if cell.editingStack.isHidden != hideEditing {
                        cell.editingStack.isHidden = hideEditing
                    }
                    if (cell.qntLabel.superview?.isHidden ?? false) != hideQnt {
                        cell.qntLabel.superview?.isHidden = hideQnt
                    }
                    if cell.categoryNameLabel.isHidden != hideTitle {
                        cell.categoryNameLabel.isHidden = hideTitle
                    }
                    if cell.dueDateStack.isHidden != hidedueDate {
                        cell.dueDateStack.isHidden = hidedueDate
                    }
                    print(selectingIconFor.0)
                    let isEditing = (editingTF == cell.newCategoryTF) || (selectingIconFor.0 == index)
                    cell.footerBackground.backgroundColor = isEditing ? selectionBacground : K.Colors.secondaryBackground

                    cell.newCategoryTF.layer.name = "cell\(index.row)"
                    let dueDate = category.category.dueDate
                   let stringDate = "\(AppData.makeTwo(n: dueDate?.day ?? 0)).\(AppData.makeTwo(n: dueDate?.month ?? 0)).\(dueDate?.year ?? 0)"
                    cell.dueDateLabel.text = stringDate
                    let expired = dateExpired(dueDate)
                    cell.dueDateIcon.tintColor = expired ? K.Colors.negative : K.Colors.category
                    cell.dueDateLabel.textColor = expired ? K.Colors.negative : K.Colors.balanceT
                    
                    cell.qntLabel.text = "\(category.transactions.count)"
                    if (AppDelegate.shared?.symbolsAllowed ?? false) {
                        let imgName = category.editing == nil ? category.category.icon : category.editing?.icon
                        cell.iconimage.image = AppData.iconSystemNamed(imgName)
                        cell.iconimage.tintColor = category.editing == nil ? AppData.colorNamed(category.category.color) : AppData.colorNamed(category.editing?.color)
                    }
                    
                    
                    cell.categoryNameLabel.text = category.category.name
                    cell.newCategoryTF.text = category.editing?.name ?? category.category.name
                    
                    return cell
                }

            }
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            return nil
        } else {
        let mainFrame = tableView.frame
        let view = UIView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: footerHeight))
        let helperView = UIView(frame: CGRect(x: 10, y: 10, width:mainFrame.width - 20, height: footerHeight - 10))
        helperView.layer.cornerRadius = tableCorners
        helperView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        helperView.backgroundColor = K.Colors.secondaryBackground//darkAppearence ? .black : .white
        view.backgroundColor = self.view.backgroundColor
        let label = UILabel(frame: CGRect(x: tableCorners + 10, y: 15, width: mainFrame.width - 40, height: 20))
        label.text = tableData[section - sectionsBeforeData].title
        label.textColor = K.Colors.balanceV
        label.font = .systemFont(ofSize: 14, weight: .medium)
        view.addSubview(helperView)
        view.addSubview(label)

        label.text = tableData[section - sectionsBeforeData].title ?? ""
        return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0
        } else {
            return screenType != .localData ? regFooterHeight : (tableCorners + 5)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0
        } else {
            return footerHeight
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            return nil
        } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.catCellIdent) as! categoriesVCcell
        /*let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
*/
            let sect = section - sectionsBeforeData
        //show only footer
        let category = tableData[sect].newCategory.category
            cell.footerHelperBottomView.isHidden = false
        cell.lo(index: nil, footer: sect)
        cell.newCategoryTF.text = category.name
            if (AppDelegate.shared?.symbolsAllowed ?? false) {
                cell.iconimage.image = AppData.iconSystemNamed(category.icon)
                cell.iconimage.tintColor = AppData.colorNamed(category.color)
            } else {
                cell.iconimage.isHidden = true
            }
        
            
        cell.editingStack.isHidden = false
        cell.dueDateStack.isHidden = true
        if cell.qntLabel.superview?.isHidden ?? false != true {
            cell.qntLabel.superview?.isHidden = true
        }
            if cell.unseenIndicatorView.isHidden != true {
                cell.unseenIndicatorView.isHidden = true
            }
        cell.cancelButton.isHidden = true
        
       /* print(category.name, "namenamenamenamenamename")
        let hideSave = category.name == "" ? true : false
        if cell.saveButton.isHidden != hideSave {
            cell.saveButton.isHidden = hideSave
        }*/
            cell.buttonsSeparetor.alpha = 0
        cell.categoryNameLabel.isHidden = true
        if screenType != .localData {
            let savePressed = UITapGestureRecognizer(target: self, action: #selector(newCategoryPressed(_:)))
            savePressed.name = "\(sect)"
            cell.saveButton.addGestureRecognizer(savePressed)
            
            let iconPressed = UITapGestureRecognizer(target: self, action: #selector(iconTapped(_:)))
            iconPressed.name = "\(sect)"
            cell.iconimage.addGestureRecognizer(iconPressed)
            cell.newCategoryTF.backgroundColor = cell.newCategoryTF == editingTF ? K.Colors.primaryBacground : .clear
            cell.newCategoryTF.delegate = self
            cell.newCategoryTF.tag = sect
            cell.newCategoryTF.addTarget(self, action: #selector(self.textfieldValueChanged), for: .editingChanged)
        } else {
            cell.iconimage.isHidden = true
            cell.editingStack.isHidden = true
            cell.saveButton.superview?.isHidden = true
        }
        

            cell.newCategoryTF.layer.name = "section\(section - sectionsBeforeData)"
        let view = cell.contentView
        view.isUserInteractionEnabled = true
        //view.layer.cornerRadius = 6
       // view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            let editingtfection = editingTfIndex.0 ?? -1
            print(editingtfection, "editingtfectioneditingtfectioneditingtfectioneditingtfection")
            let isSelected = editingtfection == sect || selectingIconFor.1 == sect
            print(isSelected, "isSelectedisSelectedisSelectedisSelected")
            view.backgroundColor = K.Colors.primaryBacground
        cell.footerBackground.backgroundColor = isSelected ? selectionBacground : K.Colors.secondaryBackground
        cell.footerBackground.layer.cornerRadius = tableCorners
        cell.footerBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }
    }


    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete".localize) {  (contextualAction, view, boolValue) in
            //self.tableActionActivityIndicator.startAnimating()
          //  DispatchQueue.main.async {
            self.ai.show(title: "Deleting".localize) { _ in
                    self.deteteCategory(at: IndexPath(row: indexPath.row, section: indexPath.section - self.sectionsBeforeData))
                }
          //  }
        }
        let localDeleteAction = UIContextualAction(style: .destructive, title: "Delete".localize) {  (contextualAction, view, boolValue) in
            //self.tableActionActivityIndicator.startAnimating()
          //  DispatchQueue.main.async {
            self.ai.show(title: "Deleting".localize) { _ in
                    let id = self.tableData[indexPath.section - self.sectionsBeforeData].data[indexPath.row].category.id
                    self.db.deleteCategory(id: "\(id)", local: true)
                    self.loadData()
                }
          //  }
            
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit".localize) {  (contextualAction, view, boolValue) in
            //self.tableActionActivityIndicator.startAnimating()
            self.tableData[indexPath.section - self.sectionsBeforeData].data[indexPath.row].editing = self.tableData[indexPath.section - self.sectionsBeforeData].data[indexPath.row].category
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .left)
               // self.tableView.reloadData()
            }
        }
        if (AppDelegate.shared?.symbolsAllowed ?? false) {
            editAction.image = AppData.iconNamed("pencil.yellow")
            deleteAction.image = AppData.iconNamed("trash.red")
            editAction.backgroundColor = K.Colors.primaryBacground
            deleteAction.backgroundColor = K.Colors.primaryBacground
            localDeleteAction.backgroundColor = K.Colors.primaryBacground
            localDeleteAction.image = AppData.iconNamed("trash.red")
        }
        
        if indexPath.section == 0 || indexPath.section == 1 {
            return nil
        } else {
            if screenType == .localData {
                return transfaringCategories == nil ? UISwipeActionsConfiguration(actions: [localDeleteAction]) : nil
            } else {
                let data = self.tableData[indexPath.section - sectionsBeforeData].data
                if data.count != 0 {
                    if data[indexPath.row].editing == nil {
                        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
                    }
                }
                return nil

                
            }
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 || indexPath.section == 1 {
        } else {
            let dataIndex = IndexPath(row: indexPath.row, section: indexPath.section - sectionsBeforeData)
            if tableData[dataIndex.section].data.count == 0 {
                
            } else {
                if let delegate = delegate {
                    delegate.categorySelected(category: tableData[dataIndex.section].data[dataIndex.row].category, fromDebts: tableData[dataIndex.section].data[dataIndex.row].category.purpose == .debt ? true : false, amount: 0)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    if tableData[dataIndex.section].data[dataIndex.row].editing == nil {
                        toHistory(index: dataIndex)
                        //(category: tableData[dataIndex.section].data[dataIndex.row].category)
                    }
                }
            }
            

        }
        
        
        


        
    }
}
