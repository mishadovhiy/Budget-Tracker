//
//  DataOptionsVC.swift
//  TSD HSAGA
//
//  Created by Mikhailo Dovhyi on 08.10.2021.
//

import UIKit

class MoreVC: SuperViewController {
    var cellBackground = K.Colors.secondaryBackground2
    
    @IBOutlet weak var tableView: UITableView!
    var dataHolder:[ScreenData] = []
    var cellHeightCust: CGFloat = 60
    var firstLaunch = true
    var firstCellHeight:CGFloat = 0
    var storyColor:UIColor?
    var scrollToHide:Bool = false
    var selectedProIndex = 0
    var bannerBackgroundWas = true
    
    var tableData:[ScreenData] {
        set {
            dataHolder = newValue
            DispatchQueue.main.async {
                if self.tableView != nil {
                    self.tableView.reloadData()
                }
            }
        }
        get {
            return dataHolder
        }
    }
    
    override func viewDidDismiss() {
        super.viewDidDismiss()
        storyColor = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.shadows()
        storyColor = self.view.backgroundColor
        self.view.backgroundColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            self.view.backgroundColor = .clear
        AppDelegate.shared?.banner.setBackground(clear: bannerBackgroundWas)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        bannerBackgroundWas = AppDelegate.shared?.banner.clearBackground ?? true
        UIView.animate(withDuration: 0.3) {
            AppDelegate.shared?.banner.setBackground(clear: true)
        //    self.view.backgroundColor = self.storyColor
        }
    }

    func loadData() {
        tableData = dataHolder
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                
            }
        }
    }

}

extension MoreVC {
    struct ScreenData {
        let name:String
        let description: String
        var distructive: Bool = false
        var showTF:Bool = false
        var showAI: Bool = true
        var selected: Bool = false
        var pro: Bool = true
        let action: (() -> ())?
    }
}


extension MoreVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        scrollToHide = scrollView.contentOffset.y < -100.0
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollToHide {
            self.dismiss(animated: true) {
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if scrollToHide {
            self.dismiss(animated: true) {
                
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            DispatchQueue.main.async {
                if touch.view != self.tableView {
                    self.dismiss(animated: true) {
                        
                    }
                }
            }
        }
    }
}


extension MoreVC {
    static func configure() -> MoreVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vccc = storyboard.instantiateViewController(withIdentifier: "MoreVC") as! MoreVC
        vccc.createPopupBackgroundView(.init(isPopupVC: true, fromWindow: true))
        return vccc
    }
}
