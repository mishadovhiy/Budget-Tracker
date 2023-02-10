//
//  DaysCollectionCell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.10.2022.
//

import UIKit

class CalendarCollectionCell: UICollectionViewCell {
    var calendarModel:CalendarModel?
    var didSelect:((_ day:Int)->())?

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    
    func set(model:CalendarModel, disp:Bool = false, didSelect:@escaping (_ day:Int)->()) {
        self.calendarModel = model
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
