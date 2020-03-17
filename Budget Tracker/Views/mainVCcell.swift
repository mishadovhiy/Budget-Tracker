//
//  mainVCcell.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class mainVCcell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}

class categoriesVCcell: UITableViewCell {
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categoryPurposeLabel: UILabel!
    
}

class PlotCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var highValueView: UIView!
    
    func setupView() {
        highValueView.layer.cornerRadius = 6
        highValueView.layer.shadowColor = UIColor.black.cgColor
        highValueView.layer.shadowOpacity = 0.2
        highValueView.layer.shadowOffset = .zero
        highValueView.layer.shadowRadius = 6
    }
    
}

class StatisticCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
}

class HistoryCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}

class HistoryCellTotal: UITableViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var perioudLabel: UILabel!
    
}
