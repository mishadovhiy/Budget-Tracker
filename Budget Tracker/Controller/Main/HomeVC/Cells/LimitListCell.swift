//
//  LimitListCell.swift
//  Budget Tracker
//
//  Created by Mykhailo Dovhyi on 04.05.2025.
//  Copyright © 2025 Misha Dovhiy. All rights reserved.
//

import UIKit

class LimitListCell: ClearCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    private var data:ViewModelHomeVC.LimitList = [:]
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collectionView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset.left = 10
        collectionView.contentInset.right = 10
    }

    func set(_ data:ViewModelHomeVC.LimitList) {
        self.data = data
        collectionView.reloadData()
    }

}

extension LimitListCell:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width - (collectionView.frame.width / 4), height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .init(describing: LimitItemCell.self), for: indexPath) as! LimitItemCell
        let key = Array(data.keys)[indexPath.row]
        cell.categoryNameLabel.text = key.name
        let value = data[key] ?? 0
        cell.progressView.progress = Float(Double(value * (value < 0 ? -1 : 1)) / Double(key.monthLimit ?? 0))
        print(cell.progressView.progress, " tgefrdc ", value)
        return cell
    }
    
    
}


class LimitItemCell: ClearCollectionCell {
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
        self.contentView.backgroundColor = .init(resource: .darkSeparetor)
        self.contentView.layer.cornerRadius = 6
        self.contentView.layer.masksToBounds = true
//        self.backgroundColor = .clear
//        self.contentView.backgroundColor = .clear
//        self.backgroundView?.backgroundColor = .clear
        categoryNameLabel.textColor = UIColor(resource: .balanceValue)
    }
}
