//
//  DaysCollectionCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.10.2022.
//

import UIKit

class CalendarCollectionCell: UICollectionViewCell {
    let selectedColor:UIColor = K.Colors.link
    var higlightDate:DateComponents?
    var calendarModel:CalendarModel?
    var didSelect:((_ day:Int)->())?
    var didSelectCell:((_ day:Int, _ cell:CalendarCell)->())?

    var vc:CalendarControlVC?
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    
    func set(model:CalendarModel, higlightDate:DateComponents?, vc:CalendarControlVC?, disp:Bool = false, didSelect:@escaping (_ day:Int)->(), cellSelectedAction:((_ day:Int, _ cell:CalendarCell)->())? = nil) {
        self.higlightDate = higlightDate
        self.vc = vc
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

class CalendarCell: ClearCollectionCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var backgroundMainView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.touchesBegunAction = { begun in
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundMainView.backgroundColor = begun ? K.Colors.link : .clear
            })
        }
    }
}
