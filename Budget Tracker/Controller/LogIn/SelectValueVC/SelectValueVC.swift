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
    
    var tableData:[SelectValueSections] = []
    var delegate: SelectUserVCDelegate?
    var titleText:String?
    var corneredTable:Bool = false
    var appeareAction:((_ vc:SelectValueVC?)->())?
    var disapeareAction:((_ vc:SelectValueVC?)->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell([.switcher])
        AppDelegate.shared!.ai.fastHide()
        title = titleText
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.name = "disabledBanner"
    }
    
    //remove //refactoring: all in \tableData
    var selectedIdxAction:((Int) -> ())?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appeareAction?(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disapeareAction?(self)
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
        var id:Int? = nil
        var forProUsers:Int? = nil
        var regular:RegularStruct? = nil
        var switcher:SwitchStruct? = nil
        struct RegularStruct {
            var disctructive:Bool = false
            var description:String? = nil
            var didSelect:()->()
        }
        struct SwitchStruct {
            let isOn:Bool
            var switched:(Bool)->()
        }
    }
    static func presentScreen(in nav:UIViewController, with data: [String], structData:[SelectValueSections]? = nil, title:String, selected: ((Int) -> ())? = nil) {

        DispatchQueue.main.async {
            let vc = SelectValueVC.configure()
            if let data = structData {
                vc.tableData = data
            } else {
                vc.tableData = [.init(sectionName: "", cells: data.compactMap({
                    .init(name: $0)
                }))]
            }
            
            vc.selectedIdxAction = selected
            vc.titleText = title
            if let navigation = nav.navigationController {
                navigation.pushViewController(vc, animated: true)

            } else {
                nav.present(vc, animated: true)
            }
        }

    }
    
    static func configure() -> SelectValueVC {
        let vc = UIStoryboard(name: "LogIn", bundle: nil).instantiateViewController(withIdentifier: "SelectValueVC") as! SelectValueVC
        return vc
    }
}
