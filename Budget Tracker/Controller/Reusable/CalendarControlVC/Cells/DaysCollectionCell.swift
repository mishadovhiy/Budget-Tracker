//
//  DaysCollectionCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.10.2022.
//

import UIKit

class CalendarCollectionCell: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var higlightDate:DateComponents?
    var calendarModel:CalendarModel?
    var didSelect:((_ day:Int)->())?
    var didSelectCell:((_ day:Int, _ cell:CalendarCell)->())?
    var vcData:PresentingData?
    
    struct PresentingData {
        var values:[String:CGFloat] = [:]
        var selectedDate:DateComponents?
        var middleDate:CalendarData?
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    
    func set(model:CalendarModel, higlightDate:DateComponents?, vc:PresentingData?, disp:Bool = false, didSelect:@escaping (_ day:Int)->(), cellSelectedAction:((_ day:Int, _ cell:CalendarCell)->())? = nil) {
        self.vcData = vc
        self.higlightDate = higlightDate
        self.calendarModel = model
        /*if let action = cellSelectedAction {
            didSelectCell = action
        } else {
            self.didSelect = didSelect
        }*/
        self.didSelect = didSelect
        if disp {
            self.collectionView.reloadData()

        }
        
    }
    
}


