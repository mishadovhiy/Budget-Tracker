//
//  SelectTextImageContainerView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 28.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

class SelectTextImageContainerView: UIViewController {
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cameraNavContainer: UIView!
    @IBOutlet weak var addTotalButton: Button!
    
    var imageNav:UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        createCameraContainer()
        tableData = []
    }
    
    var currentSelectingData:[SelectionData] = []
    private func createCameraContainer() {
        let vc = CameraTextMLVC.configure(delegate: self)
        let nav = UINavigationController(rootViewController: vc)
        addChild(nav)
        guard let childView = nav.view else {
            return
        }
        cameraNavContainer.addSubview(childView)
        childView.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superV: cameraNavContainer)
        nav.didMove(toParent: self)
        imageNav = nav
        vc.disapeareAction = { _ in
            self.currentSelectingData = []

        }
    }

    @IBAction func addTotalPressed(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let value = tableData
            let vc = imageNav?.viewControllers.last(where: {$0 is ImagePreviewVC}) as! ImagePreviewVC
            vc.updateSelections([])
        }
        
    }
    
    var tableData:[SelectionData] = [] {
        didSet {
            var total = 0
            tableData.forEach({total += $0.number})
            let str: NSMutableAttributedString = .init(string: "Total: ")
            str.append(.init(string: "\(total)", attributes: [
                .font:UIFont.systemFont(ofSize: 17, weight: .semibold)
            ]))
            totalLabel.attributedText = str
            if (total == 0) != (totalLabel.superview?.isHidden ?? false) {
                totalLabel.superview?.fadeTransition(0.2)
                totalLabel.superview?.isHidden = total == 0
            }
        }
    }
}

extension SelectTextImageContainerView:ImagePreviewProtocol {
    func textSelected(_ all: [String]) {
        tableData = all.filter({
            if let _ = $0.filterNumber {
                return true
            } else {
                return false
            }
        }).compactMap({
            return .init(number: $0.filterNumber ?? -1, strKey: $0)
        })
        print(tableData.count, " gterfwed")
        tableView.reloadData()
    }
    
}

extension SelectTextImageContainerView:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectImageCell", for:indexPath) as! SelectImageCell
        cell.set(str: "\(tableData[indexPath.row].number)")
        return cell
    }
    
    
}

class SelectImageCell:UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    func set(str:String) {
        titleLabel.text = str
    }
}

extension SelectTextImageContainerView {
    struct SelectionData {
        let number:Int
        let strKey:String
    }
    static func configure() -> SelectTextImageContainerView {
        let vc = UIStoryboard(name: "Reusable", bundle: nil).instantiateViewController(withIdentifier: "SelectTextImageContainerView") as! SelectTextImageContainerView
        return vc
    }
}
