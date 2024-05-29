//
//  CollectionViewCalendar.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 08.10.2022.
//

import UIKit

extension CalendarCollectionCell:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarModel?.days.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        let days = calendarModel?.days ?? []
        let day = days[indexPath.row] != 0 ? "\(days[indexPath.row])" : ""
        cell.dayLabel.text = day
       /* let dayCell = days[indexPath.row]
        let monthCell = calendarModel?.month ?? 0
        let yearCell = calendarModel?.year ?? 0
        let day = "\(dayCell).\(monthCell).\(yearCell)"
        let color:UIColor = K.Colors.Text.white//calendarModel?.today.desription ?? "" == day ? .red : K.Colors.Text.white
        cell.dayLabel.textColor = color
        */
        
        let dayOpt = vcData?.middleDate
        let today = Date().toDateComponents()
        let isToday = today.year == dayOpt?.year && today.month == dayOpt?.month && today.day == Int(day)
        cell.dayLabel.textColor = isToday ? .red : .white
        let selectedMonth = vcData?.selectedDate
        let value = vcData?.values["\(dayOpt?.year ?? 0).\(dayOpt?.month ?? 0).\(day)"]
        let plus = (value ?? 0) > 0 ? "+" : ""
        cell.valueLabel.text = value == nil ? " " : "\(plus)\(Int(Double(value ?? 0)))"
        let selectedDate = higlightDate ?? selectedMonth
        let isSelected = calendarModel?.month ?? -1 == selectedDate?.month ?? -1 && calendarModel?.year ?? -1 == selectedDate?.year ?? -1 && days[indexPath.row] == selectedDate?.day ?? -1
        if isSelected {
            print("isSelectedisSelected ", indexPath.row)
        }
        cell.backgroundMainView.backgroundColor = isSelected ?  K.Colors.link : .clear

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let days = calendarModel?.days ?? []
        let day = days[indexPath.row]
        if day != 0 {
            if let daySelected = didSelect {
                daySelected(day)
            } 
        }
        

    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    

    }
}
