//
//  UICollectionViewDelegate_CalendarControlVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 09.10.2022.
//

import UIKit

extension CalendarControlVC:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //check calendarType
        return tableData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionCell", for: indexPath) as! CalendarCollectionCell
        cell.set(model: tableData[indexPath.row], higlightDate: higlightSelected ? selectedDateComponent : nil, vc: .init(values:values, selectedDate: selectedDate, middleDate: middleDate), disp: true, didSelect: daySelected(_:), cellSelectedAction: cellSelected == nil ? nil : daySelectedCell(_:cell:))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionCell", for: indexPath) as! CalendarCollectionCell
        cell.set(model: tableData[indexPath.row], higlightDate: higlightSelected ? selectedDateComponent : nil, vc: .init(values: values, selectedDate: selectedDate, middleDate: middleDate), disp: true, didSelect: daySelected(_:),cellSelectedAction: daySelectedCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width,
                     height: collectionView.frame.height)
    }
    
}
