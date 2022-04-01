//
//  BuyPageVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class BuyPageVC: UIPageViewController {

    let pages: [PageStruct] = [
        PageStruct(title: "Payment reminders".localize, description: "Set repeated or one time reminders. Easy as adding new transaction".localize, imgName: "addReminder.pro"),
        PageStruct(title: "Transfer data".localize, description: "Transfer transactions and categories between accounts".localize, imgName: "transfareDataIcon.pro"),
        PageStruct(title: "Passcode protection".localize, description: "Set 4 digit passcode".localize, imgName: "passcodeProtect.pro"),
        PageStruct(title: "App storage increase and more".localize, description: "• Create up to 15 accounts for email\n• Stores more data about app usage\n• Set link color".localize, imgName: "dbStorage.pro"),
    ]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createVCS()
    }
    
    func createVCS() {
        
        var result:[UIViewController] = []
        let pags = pages
        
        DispatchQueue.main.async {
            for i in 0..<pags.count {
                let vc = UIStoryboard(name: "LogIn", bundle: nil).instantiateViewController(withIdentifier: "ProViewVC") as! ProViewVC
                vc.data = pags[i]
                result.append(vc)
            }
            self.tableData = result
            if let firstPage = self.tableData.first {
                self.setViewControllers([firstPage], direction: .forward, animated: true) { _ in
                    if BuyProVC.shared?.selectedProduct ?? 0 != 0 {
                        self.setViewControllers([self.tableData[BuyProVC.shared?.selectedProduct ?? 0]], direction: .forward, animated: true) { _ in
                            
                        }
                    }
                    
                }
                
                
          }
        }
    }
    
    var tableData:[UIViewController] = []

}

extension BuyPageVC {
    struct PageStruct {
        let title: String
        let description: String
        let imgName: String
    }
}

extension BuyPageVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return tableData.count
    }
    

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let pageIndex = tableData.firstIndex(of: viewController) else { return nil }
        let previousIndex = pageIndex - 1
        guard previousIndex >= 0 else {
            return nil
            
        }
        guard tableData.count > previousIndex else {
            return nil
            
        }
        let vc = tableData[previousIndex] as! ProViewVC
        vc.data = pages[previousIndex]
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
      //  pages.
        guard let pageIndex = tableData.firstIndex(of: viewController) else { return nil }
        let nextIndex = pageIndex + 1
        let pageCount = tableData.count
        guard nextIndex != pageCount else {
            return nil }
        guard pageCount > nextIndex else {
            return nil }
        let vc = tableData[nextIndex] as! ProViewVC
        vc.data = pages[nextIndex]
        return vc
    }
}
