//
//  SelectUserVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 09.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class SelectValueVC: SuperViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak static var shared:SelectValueVC?
    var tableData:[SelectValueSections] = []
    var delegate: SelectUserVCDelegate?
    var titleText:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell([.switcher])
        SelectValueVC.shared = self
        AppDelegate.shared!.ai.fastHide()
        title = titleText
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //remove //refactoring: all in \tableData
    var selectedIdxAction:((Int) -> ())?

}

extension SelectValueVC:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let regular = tableData[indexPath.section].cells[indexPath.row].regular {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectUserVCCell", for: indexPath) as! SelectUserVCCell
            cell.mainTitleLabel.text = tableData[indexPath.section].cells[indexPath.row].name
            return cell
        } else if let switcher = tableData[indexPath.section].cells[indexPath.row].switcher {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.set(title:tableData[indexPath.section].cells[indexPath.row].name,
                     isOn: switcher.isOn, changed: switcher.switched)
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    private func dismissOnSelect() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true) {
                
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            if let delegate = self.delegate {
                delegate.selected(user: self.tableData[indexPath.section].cells[indexPath.row].name)
                dismissOnSelect()
            } else if let selectedIdx = self.selectedIdxAction {
                selectedIdx(indexPath.row)
                dismissOnSelect()
            } else {
                self.tableData[indexPath.section].cells[indexPath.row].regular?.didSelect()
            }
            
    }
}






protocol SelectUserVCDelegate {
    func selected(user: String)
}

extension SelectValueVC {
    struct SelectValueSections {
        let sectionName:String
        let cells:[SelectValueStruct]
    }
    struct SelectValueStruct {
        let name:String
        var regular:RegularStruct? = nil
        var switcher:SwitchStruct? = nil
        
        struct RegularStruct {
            var description:String? = nil
            var didSelect:()->()
        }
        struct SwitchStruct {
            let isOn:Bool
            var switched:(Bool)->()
        }
    }
    public func presentScreen(in nav:UINavigationController, with data: [String], title:String, selected:@escaping (Int) -> ()) {

        DispatchQueue.main.async {
            let vc = SelectValueVC.configure()
            vc.tableData = [.init(sectionName: "", cells: data.compactMap({
                .init(name: $0)
            }))]
            vc.selectedIdxAction = selected
            vc.titleText = title
            nav.pushViewController(vc, animated: true)
        }

    }
    
    static func configure() -> SelectValueVC {
        let vc = UIStoryboard(name: "LogIn", bundle: nil).instantiateViewController(withIdentifier: "SelectValueVC") as! SelectValueVC
        return vc
    }
}
