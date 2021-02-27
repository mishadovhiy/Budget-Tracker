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

class FilterTVC: UIViewController {
    var months: [String] = []
    var years: [String] = []
    var sectionsCount = 3
    var buttonTitle = ["All Time", "This Month", "Today", "Yesterday", "Custom"]
    
    @IBOutlet weak var tableview: UITableView!
    
    var frame = CGRect.zero
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.delegate = self
        tableview.dataSource = self
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view != tableview {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
                }
            }
        }
    }
    
    var vcAppeared = false
    override func viewWillLayoutSubviews() {
        
    }
    
    override func viewDidLayoutSubviews() {
        if !vcAppeared {
            vcAppearence()
        }
    }
    
    func vcAppearence() {
        vcAppeared = true
        DispatchQueue.main.async {
            self.tableview.beginUpdates()
            self.tableview.cellLayoutMarginsFollowReadableWidth = true
            self.tableview.translatesAutoresizingMaskIntoConstraints = true
            self.tableview.layer.masksToBounds = true
            self.tableview.layer.cornerRadius = 9
            self.tableview.alpha = 1
            self.tableview.layer.frame = CGRect(x: self.frame.minX, y: 0, width: self.frame.width, height: self.frame.height)
            
            UIView.animate(withDuration: 0.2) {
                self.tableview.layer.frame = self.frame
            } completion: { (_) in
                self.tableview.cellLayoutMarginsFollowReadableWidth = true
                self.tableview.endUpdates()
                self.tableview.reloadData()
                for i in 0..<self.tableview.visibleCells.count {
                    self.tableview.visibleCells[i].translatesAutoresizingMaskIntoConstraints = true
                    let cellFrame = self.tableview.visibleCells[i].frame
                    self.tableview.visibleCells[i].frame = CGRect(x: cellFrame.minX, y: cellFrame.minY, width: self.frame.width, height: cellFrame.height)
                }
            }
        }
        
    }
    

    
    
    @IBAction func closePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
        }
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
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
            }
            
        case 1:
            appData.filter.showAll = false
            defaultFilter()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
            }
            
        case 2:
            appData.filter.showAll = false
            appData.filter.from = today
            appData.filter.to = today
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
            }
            
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
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
            }
            
        case 4:
            appData.filter.showAll = false
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: K.toCalendar, sender: self)
            }
            
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
            1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr", 5: "May", 6: "June",
            7: "July", 8: "Aug", 9: "Sept", 10: "Oct", 11: "Nov", 12: "Dec"
        ]
        return monthes[int] ?? "Jan"
    }
    
    func secondSectionSelected(i: Int) {

        appData.filter.showAll = false
        let date = "01.\(months[i])"
        let toIntDay = appData.filter.getLastDayOf(fullDate: date)
        appData.filter.from = date
        appData.filter.to = "\(toIntDay).\(months[i])"
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
        }

    }
    
    func thirdSectionSelected(i: Int) {
        
        appData.filter.showAll = false
        appData.filter.from = "01.01.\(years[i])"
        appData.filter.to = "31.12.\(years[i])"
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
        }
        
    }
    
    @IBAction func unwindCalendarClosed(segue: UIStoryboardSegue) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            if appData.filter.from == "" || appData.filter.to == "" {
                self.defaultFilter()
                selectedPeroud = "\(self.buttonTitle[1])"
                ifCustom = false
                appData.filter.showAll = false
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
                self.prepareCustomDates()
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
            selectedPeroud = "\(convertMonthFrom(int: month)) \(day) → \(convertMonthFrom(int: monthTo)) \(dayTo), \(yearTo)"
        } else {
            selectedPeroud = "\(convertMonthFrom(int: month)) \(day), \(year) → \(convertMonthFrom(int: monthTo)) \(dayTo), \(yearTo)"
        }
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: K.quitFilterTVC, sender: self)
        }
        
    }

    
    
// MARK: - Table view data source
    
    
}


extension FilterTVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return buttonTitle.count
        case 1: return months.count
        case 2: return years.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.translatesAutoresizingMaskIntoConstraints = true
        let cellFrame = cell.frame
        cell.frame = CGRect(x: cellFrame.minX, y: cellFrame.minY, width: tableView.frame.width, height: cellFrame.height)
        print(cellFrame, cell.frame)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.filterCell, for: indexPath) as! FilterCell

        var data = ""
        switch indexPath.section {
        case 0:
            data = buttonTitle[indexPath.row]
        case 1:
            let month = appData.filter.getMonthFromString(s: "01.\(months[indexPath.row])")
            let year = appData.filter.getYearFromString(s: "01.\(months[indexPath.row])")
            data = "\(convertMonthFrom(int: month)), \(year)"
            
        case 2:
            data = years[indexPath.row]
            
        default:
            return UITableViewCell()
        }

        if data == selectedPeroud {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 6
           // cell.titleLabel.textColor = K.Colors.category
            cell.backgroundColor = K.Colors.yellow//UIColor(named: "darkTableColor") //K.Colors.yellow
        } else {
            cell.backgroundColor = .clear
            //cell.titleLabel.textColor = K.Colors.yellow//UIColor(named: "darkTableColor")
        }
        if ifCustom {
            if data == "Custom" {
                cell.layer.masksToBounds = true
                cell.layer.cornerRadius = 6
                cell.backgroundColor = K.Colors.yellow//UIColor(named: "darkTableColor")
               // cell.titleLabel.textColor = K.Colors.category
            }
        }
        
        cell.titleLabel.text = data
        
    
        return cell
        
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        
        switch section {
        case 0: return 0
        case 1: return months.count == 0 ? 0 : 20
        case 2: return years.count == 0 ? 0 : 20
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        let label = UILabel()
        label.frame = CGRect(x: 10, y: 0, width: self.frame.width, height: 20)
        label.font = label.font.withSize(10)
        label.textColor = K.Colors.balanceT
        
        switch section {
        case 0: label.text = ""
        case 1: label.text = months.count > 0 ? "Months": ""//getTitleSectionFor(data: months, title: "Months")
        case 2: label.text = years.count > 0 ? "Years": ""//getTitleSectionFor(data: years, title: "Years")
        default:
            label.text = ""
        }
        view.backgroundColor = UIColor(red: 190/255, green: 185/255, blue: 185/255, alpha: 1) //UIColor(named: "darkTableColor") //K.Colors.separetor//UIColor(named: "darkTableColor")
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        
        print("filterVC: appData.filter.from: \(appData.filter.from), appData.filter.to: \(appData.filter.to)")
        
    }
}
