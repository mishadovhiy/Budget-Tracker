//
//  SelectTextImageContainerView.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 28.11.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

protocol SelectTextImageContainerViewProtocol {
    func totalChanged(_ total:Int)
}

class SelectTextImageContainerView: UIViewController {
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cameraNavContainer: UIView!
    @IBOutlet weak var addTotalButton: Button!
    
    var imageNav:UINavigationController?
    var delegate:SelectTextImageContainerViewProtocol?
    private var cameraTextVC:CameraTextMLVC?
    var currentSelectingData:[SelectionData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.delegate = self
//        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        createCameraContainer()
        tableData = []
    }
    
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
            var data = self.tableData
            self.currentSelectingData.forEach {
                data.append(.init(number: $0.number, strKey: ""))
            }
            self.currentSelectingData = []
            self.tableData = data
        }
        nav.setBackground(.clear)
        cameraTextVC = vc
    }

    func updateCameraVCData() {
        if #available(iOS 13.0, *) {
            if let vc = imageNav?.viewControllers.last(where: {$0 is ImagePreviewVC}) as? ImagePreviewVC {
                vc.updateSelections(currentSelectingData.compactMap({$0.strKey}))
            }
        }
    }
    
    @IBAction func addTotalPressed(_ sender: Any) {
        updateCameraVCData()
        
    }
    
    func tableUpdated() {
        var total = 0
        currentSelectingData.forEach({total += $0.number})
        tableData.forEach({total += $0.number})
//            let str: NSMutableAttributedString = .init(string: "Total: ")
//            str.append(.init(string: "\(total)", attributes: [
//                .font:UIFont.systemFont(ofSize: 17, weight: .semibold)
//            ]))
//            totalLabel.attributedText = str
//            if (total == 0) != (totalLabel.superview?.isHidden ?? false) {
//                totalLabel.superview?.fadeTransition(0.2)
//                totalLabel.superview?.isHidden = total == 0
//            }
        delegate?.totalChanged(total)
        collectionView.reloadData()
    }
    
    func toggleCameraSession(pause:Bool, remove:Bool = false) {
        if pause {
            cameraTextVC?.cameraModel.stop()

        } else {
            cameraTextVC?.cameraModel.resume()
        }
        if remove {
            cameraTextVC = nil
        }
    }
    
    var tableData:[SelectionData] = [] {
        didSet {
            self.tableUpdated()
        }
    }
    
    func deletePressed(_ at:IndexPath) {
        if at.section == 0 {
            currentSelectingData.remove(at: at.row)
            tableUpdated()
        } else if at.section == 1 {
            tableData.remove(at: at.row)
        }
        updateCameraVCData()
    }
}

extension SelectTextImageContainerView:ImagePreviewProtocol {
    func textSelected(_ all: [String]) {
        currentSelectingData = all.filter({
            if let n = $0.filterNumber, n != 0 {
                return true
            } else {
                return false
            }
        }).compactMap({
            return .init(number: $0.filterNumber ?? -1, strKey: $0)
        })
        tableUpdated()
        print(tableData.count, " gterfwed")
    }
    
}


extension SelectTextImageContainerView:UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return currentSelectingData.count
        case 1: return tableData.count
        default: return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectImageCollectionCell", for: indexPath) as! SelectImageCollectionCell
        let data = indexPath.section == 0 ? currentSelectingData : tableData
        cell.set(str: "\(data[indexPath.row].number)", deletePressed: {
            self.deletePressed(indexPath)
        })
        return cell
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
