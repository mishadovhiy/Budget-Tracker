//
//  BuyPageVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 29.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

class BuyPageVC: UIPageViewController {

    var pages: [PageStruct] = [
        PageStruct(title: "Transfare data", description: "some description"),
        PageStruct(title: "Due date reminder for debts", description: "set notification reminder for specific date"),
        PageStruct(title: "Data base storage increes", description: "create up to: 15 data base usernames per email"),
    ]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableData = createVCS()
        createVCS()

        dataSource = self
        delegate = self
    }
    var selectedNum = 1
    
    func createVCS() {
        
        var result:[UIViewController] = []

        for i in 0..<pages.count {
            let vc = UIStoryboard(name: "LogIn", bundle: nil).instantiateViewController(withIdentifier: "ProViewVC") as! ProViewVC
            vc.data = pages[i]
            result.append(vc)

            
        }
        tableData = result
        DispatchQueue.main.async {
            if let firstPage = self.tableData.first {
                self.setViewControllers([firstPage], direction: .forward, animated: true) { _ in
                    if self.selectedNum != 0 {
                        self.setViewControllers([self.tableData[self.selectedNum]], direction: .forward, animated: true) { _ in
                            
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
