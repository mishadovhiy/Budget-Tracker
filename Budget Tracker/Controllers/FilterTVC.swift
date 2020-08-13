//
//  FilterTVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 22.04.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CoreData

var ifCustom = false

class FilterTVC: UITableViewController {
    var months = [""]
    var years = [""]
    var sectionsCount = 3
    var buttonTitle = ["All Time", "This Month", "Today", "Yesterday", "Custom"]
    let data = appData.transactions
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
        if months.first == "" {
            months.removeFirst()
        }
        if years.first == "" {
            years.removeFirst()
        }
        
    }
    
    func getData() {
        
        appendMatches()
    }

    func appendMatches() {
        
        for i in 0..<data.count {
            if !months.contains(removeDayFromString(data[i].date)) {
                months.append(removeDayFromString(data[i].date))
            }
            
            if !years.contains(removeDayMonthFromString(data[i].date)) {
                years.append(removeDayMonthFromString(data[i].date))
            }
        }
    }
    
    func removeDayFromString(_ s: String) -> String {
        
        var m = s
        for _ in 0..<3 {
            m.removeFirst()
        }
        return m
    }
    
    func removeDayMonthFromString(_ s: String) -> String {
        
        var m = s
        for _ in 0..<6 {
            m.removeFirst()
        }
        return m
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getTitleSectionFor(data: [String], title: String) -> String {
        
        var t = title
        if data.count != 0 {
            if data.count < 2 {
                t.removeLast()
            }
        } else {
            t.removeAll()
        }
        return t
    }
    
    func firstSectionSelected(i: Int) {
        
        let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        
        switch i {
        case 0:
            appData.filter.from = ""
            appData.filter.to = ""
            appData.filter.showAll = true
            self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
            
        case 1:
            appData.filter.showAll = false
            defaultFilter()
            self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
            
        case 2:
            appData.filter.showAll = false
            appData.filter.from = today
            appData.filter.to = today
            self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
            
        case 3:
            appData.filter.showAll = false
            let todayInt = appData.filter.getDayFromString(s: today)
            let month = appData.filter.getMonthFromString(s: today)
            let year = appData.filter.getYearFromString(s: today)
            
            if todayInt > 1 {
                appData.filter.from = "\(appData.filter.makeTwo(n: todayInt - 1)).\(appData.filter.makeTwo(n: month)).\(year)"
                appData.filter.to = appData.filter.from
            } else {
                if month > 1 {
                    let prevMonth = month - 1
                    let lastDayOfMonth = appData.filter.getLastDayOf(month: prevMonth, year: year)
                    appData.filter.from = "\(lastDayOfMonth).\(appData.filter.makeTwo(n: prevMonth)).\(year)"
                    appData.filter.to = appData.filter.from
                } else {
                    appData.filter.from = "31.12.\(year - 1)"
                    appData.filter.to = appData.filter.from
                }
            }
            self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
            
        case 4:
            appData.filter.showAll = false
            self.performSegue(withIdentifier: K.toCalendar, sender: self)
            
        default:
            print("def")
        }
        
    }
    
    func defaultFilter() {
        
        let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        let month = appData.filter.getMonthFromString(s: today)
        let year = appData.filter.getYearFromString(s: today)
        let dayTo = appData.filter.getLastDayOf(month: month, year: year)
        
        appData.filter.from = "01.\(appData.filter.makeTwo(n: month)).\(year)"
        appData.filter.to = "\(dayTo).\(appData.filter.makeTwo(n: month)).\(year)"
    }
    
    func convertMonthFrom(int: Int) -> String {
        
        let monthes = [
            1: "January", 2: "February", 3: "March", 4: "April", 5: "May", 6: "June",
            7: "July", 8: "August", 9: "September", 10: "October", 11: "November", 12: "December"
        ]
        return monthes[int] ?? "Jan"
    }
    
    func secondSectionSelected(i: Int) {

        appData.filter.showAll = false
        let date = "01.\(months[i])"
        let toIntDay = appData.filter.getLastDayOf(fullDate: date)
        appData.filter.from = date
        appData.filter.to = "\(toIntDay).\(months[i])"
        self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
        
    }
    
    func thirdSectionSelected(i: Int) {
        
        appData.filter.showAll = false
        appData.filter.from = "01.01.\(years[i])"
        appData.filter.to = "31.12.\(years[i])"
        self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
    }
    
    @IBAction func unwindCalendarClosed(segue: UIStoryboardSegue) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                if appData.filter.from == "" || appData.filter.to == "" {
                    self.defaultFilter()
                    selectedPeroud = "\(self.buttonTitle[1])"
                    ifCustom = false
                    appData.filter.showAll = false
                    self.tableView.reloadData()
                } else {
                    self.tableView.reloadData()
                    self.prepareCustomDates()
                }
            }
        }
    }
    
    func prepareCustomDates() {
        
        let day = appData.filter.getDayFromString(s: appData.filter.from)
        let month = appData.filter.getMonthFromString(s: appData.filter.from)
        let year = appData.filter.getYearFromString(s: appData.filter.from)
        
        let dayTo = appData.filter.getDayFromString(s: appData.filter.to)
        let monthTo = appData.filter.getMonthFromString(s: appData.filter.to)
        let yearTo = appData.filter.getYearFromString(s: appData.filter.to)
        ifCustom = true
        if yearTo == year {
            selectedPeroud = "\(convertMonthFrom(int: month)), \(day) → \(convertMonthFrom(int: monthTo)), \(dayTo) of \(yearTo)"
        } else {
            selectedPeroud = "\(convertMonthFrom(int: month)), \(day) of \(year) → \(convertMonthFrom(int: monthTo)), \(dayTo) of \(yearTo)"
        }
        
        self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
    }
    
    
// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return buttonTitle.count
        case 1: return months.count
        case 2: return years.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.filterCell, for: indexPath) as! FilterCell
        switch indexPath.section {
        case 0:
            let data = buttonTitle[indexPath.row]
            cell.titleLabel.text = data
            
        case 1:
            let month = appData.filter.getMonthFromString(s: "01.\(months[indexPath.row])")
            let year = appData.filter.getYearFromString(s: "01.\(months[indexPath.row])")
            let data = "\(convertMonthFrom(int: month)), \(year)"
            cell.titleLabel.text = data
            
        case 2:
            let data = years[indexPath.row]
            cell.titleLabel.text = data
            
        default:
            return UITableViewCell()
        }
        
        if cell.titleLabel.text == selectedPeroud {
            cell.backgroundCell.layer.masksToBounds = true
            cell.backgroundCell.layer.cornerRadius = 6
            cell.backgroundCell.backgroundColor = K.Colors.pink
        } else {
            cell.backgroundCell.backgroundColor = UIColor.clear
        }
        if ifCustom {
            if cell.titleLabel.text == "Custom" {
                cell.backgroundCell.layer.masksToBounds = true
                cell.backgroundCell.layer.cornerRadius = 6
                cell.backgroundCell.backgroundColor = K.Colors.pink
            }
        }
        
        return cell
        
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        } else {
            return 20
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        let label = UILabel()
        label.frame = CGRect(x: 15, y: 0, width: UIScreen.main.bounds.width, height: 20)
        label.font = label.font.withSize(10)
        label.textColor = K.Colors.balanceT
        
        switch section {
        case 0: label.text = ""
        case 1: label.text = getTitleSectionFor(data: months, title: "Months")
        case 2: label.text = getTitleSectionFor(data: years, title: "Years")
        default:
            label.text = ""
        }
        
        view.addSubview(label)
        view.backgroundColor = K.Colors.sectionBackground
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? FilterCell {
            selectedPeroud = cell.titleLabel.text ?? "Unknown"
            
            if cell.titleLabel.text != "Custom" {
                ifCustom = false
            }
        }
        
        switch indexPath.section {
        case 0: firstSectionSelected(i: indexPath.row)
        case 1: secondSectionSelected(i: indexPath.row)
        case 2: thirdSectionSelected(i: indexPath.row)
        default:
            print("def")
        }
        
    }
    
}
