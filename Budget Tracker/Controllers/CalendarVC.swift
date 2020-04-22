//
//  CalendarVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 22.04.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class CalendarVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var doneButton: UIButton!
    
    var selectedFrom = ""
    var selectedTo = ""
    var days = [0]
    var daysBetween = [""]
    var selectedFromDayInt = 0
    var selectedToDayInt = 0
    
    var year = 1996
    var month = 11
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updaiteUI()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        if ifCustom {
            selectedFrom = appData.filter.from
            selectedTo = appData.filter.to
            selectedFromDayInt = appData.filter.getDayFromString(s: selectedFrom)
            selectedToDayInt = appData.filter.getDayFromString(s: selectedTo)
            ifToSmaller()
            
            year = getYearFrom(string: selectedFrom)
            month = getMonthFrom(string: selectedFrom)
            getDays()
            getBetweens()
            doneIsActive = true
            doneButtonIsActive()
            ifEndInvisible()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func ifEndInvisible() {
        
        let year = getYearFrom(string: selectedFrom)
        let month = getMonthFrom(string: selectedFrom)
        let yearTo = getYearFrom(string: selectedTo)
        let monthTo = getMonthFrom(string: selectedTo)
        if year != yearTo {
            toggleButton(b: endButton, hidden: false)
            goButtonsTitle()
        } else {
            if month != monthTo {
                toggleButton(b: endButton, hidden: false)
                goButtonsTitle()
            }
        }
    }
    
    func updaiteUI() {
        
        collectionView.delegate = self
        collectionView.dataSource = self

        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeForward))
        swipeLeft.direction = .left;

        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeBack))
        swipeRight.direction = .right;
        
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)
        appData.styles.cornerRadius(buttons: [startButton, endButton])
        
        let today = appData.filter.getToday(appData.filter.filterObjects.currentDate)
        year = appData.filter.getYearFromString(s: today)
        month = appData.filter.getMonthFromString(s: today)
        getDays()
        
        print("called")
        if selectedTo == "" && selectedFrom == "" {
            toggleButton(b: startButton, hidden: true)
            toggleButton(b: endButton, hidden: true)
            doneButtonIsActive()
        }
    }
    
    func getDays() {
        
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        days.removeAll()
        for i in 0..<numDays {
            days.append(i+1)
        }
        textField.text = "\(returnMonth(month)), \(year)"
        
    }
    
    func setYear() {
        if month == 13 {
            month = 1
            year = year + 1
        }
        if month == 0 {
            month = 12
            year = year - 1
        }
    }
    
    func returnMonth(_ month: Int) -> String {
        let monthes = [
            1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr", 5: "May", 6: "Jun",
            7: "Jul", 8: "Aug", 9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec"
        ]
        return monthes[month] ?? "Jan"
    }
    
    @IBAction func changeMonthPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            month = month - 1
            setYear()
            getDays()
        } else {
            month = month + 1
            setYear()
            getDays()
        }
        collectionView.reloadData()
        if selectedFrom != "" || selectedTo != "" {
            goButtonsTitle()
        }
    }
    
    
    @IBAction func swipeForward(gestureRecognizer:UISwipeGestureRecognizer) {
        
        month = month + 1
        setYear()
        getDays()
        collectionView.reloadData()
        if selectedFrom != "" || selectedTo != "" {
            goButtonsTitle()
        }
    }
    
    @IBAction func swipeBack(gestureRecognizer:UISwipeGestureRecognizer) {
        
        month = month - 1
        setYear()
        getDays()
        collectionView.reloadData()
        if selectedFrom != "" || selectedTo != "" {
            goButtonsTitle()
        }
    }
    
    func ifToSmaller() {
    
        if selectedFrom != "" && selectedTo != "" {
            let yearFromS = getYearFrom(string: selectedFrom)
             let yearToS = getYearFrom(string: selectedTo)
             let monthFromS = getMonthFrom(string: selectedFrom)
             let monthToS = getMonthFrom(string: selectedTo)
             let dayFromS = selectedFromDayInt
             let dayToS = selectedToDayInt
             let holdlerTo = selectedTo
             
             if yearFromS > yearToS {
                selectedTo = selectedFrom
                selectedFrom = holdlerTo
                selectedToDayInt = selectedFromDayInt
                selectedFromDayInt = dayToS

             } else {
                 if yearFromS == yearToS {
                     if monthFromS > monthToS {
                        selectedTo = selectedFrom
                        selectedFrom = holdlerTo
                        selectedToDayInt = selectedFromDayInt
                        selectedFromDayInt = dayToS
                     }
                     if monthFromS == monthToS {
                         if dayFromS > dayToS {
                            selectedTo = selectedFrom
                            selectedFrom = holdlerTo
                            selectedToDayInt = selectedFromDayInt
                            selectedFromDayInt = dayToS
                         }
                     }
                 }
             }
        }
        
    }
    
    func removeSelected(cell: CVCell) {
        
        if selectedTo == cell.cellTypeLabel.text {
            selectedTo = ""
            selectedToDayInt = 0
        }
        if selectedFrom == cell.cellTypeLabel.text {
            selectedFrom = ""
            selectedFromDayInt = 0
        }
    }
    
    func getMonthFrom(string: String) -> Int {
        
        if string != "" {
            var monthS = string
            for _ in 0..<3 {
                monthS.removeFirst()
            }
            for _ in 0..<5 {
                monthS.removeLast()
            }
            return Int(monthS) ?? 11
        } else {
            return 11
        }
    }
    
    func getYearFrom(string: String) -> Int {
        
        if string != "" {
            var yearS = string
            for _ in 0..<6 {
                yearS.removeFirst()
            }
            return Int(yearS) ?? 1996
            
        } else {
            return 1996
        }
    }
    
    func getBetweens() {
        
        daysBetween.removeAll()
        if selectedFrom != "" && selectedTo != "" {
            if getYearFrom(string: selectedTo) == getYearFrom(string: selectedFrom) && (getMonthFrom(string: selectedTo) == getMonthFrom(string: selectedFrom)) {
                
                let dayFrom = appData.filter.getDayFromString(s: selectedFrom)
                let dayTo = appData.filter.getDayFromString(s: selectedTo)
                let between = (dayTo - dayFrom) - 1
                var start = dayFrom
                for _ in 0..<between {
                    
                    let dayCell = makeTwo(n: days[start])
                    let monthCell = makeTwo(n: month)
                    let yearCell = makeTwo(n: year)
                    daysBetween.append("\(dayCell).\(monthCell).\(yearCell)")
                    start += 1
                }
            } else {
                allDaysBetween()
            }

        }
        
    }
    
    func allDaysBetween() {
        
        if getYearFrom(string: selectedTo) == getYearFrom(string: selectedFrom) {
            let monthDifference = (getMonthFrom(string: selectedTo) - getMonthFrom(string: selectedFrom)) - 1
            var amount = selectedToDayInt + (31 - selectedFromDayInt) + (monthDifference * 31)
            if amount < 0 {
                amount *= -1
            }
            calculateDifference(amount: amount)

        } else {
            let yearDifference = (getYearFrom(string: selectedTo) - getYearFrom(string: selectedFrom)) - 1
            let monthDifference = (12 - getMonthFrom(string: selectedFrom)) + (yearDifference * 12) + getMonthFrom(string: selectedTo)
            var amount = selectedToDayInt + (31 - selectedFromDayInt) + (monthDifference * 31)
            if amount < 0 {
                amount *= -1
            }
            calculateDifference(amount: amount)
        }
        
    }
    
    func calculateDifference(amount: Int) {
        
        var dayA: Int = selectedFromDayInt
        var monthA: Int = getMonthFrom(string: selectedFrom)
        var yearA: Int = getYearFrom(string: selectedFrom)
        for _ in 0..<amount {
            dayA += 1
            if dayA == 32 {
                dayA = 1
                monthA += 1
                if monthA == 13 {
                    monthA = 1
                    yearA += 1
                }
            }
            let new: String = "\(makeTwo(n: dayA)).\(makeTwo(n: monthA)).\(makeTwo(n: yearA))"
            if new == selectedTo {
                break
            }
            daysBetween.append(new)
        }
    }
    
    func cellBackground(cell: CVCell) {
        
        if selectedTo == cell.cellTypeLabel.text || selectedFrom == cell.cellTypeLabel.text {
            cell.backgroundCell.backgroundColor = K.Colors.yellow
            cell.dayLabel.textColor = UIColor.white
        }else {
            cell.backgroundCell.backgroundColor = UIColor.clear
            cell.dayLabel.textColor = K.Colors.category
        }
        
    }
    
    func backgroundBetween(cell: CVCell) {
        
        for i in 0..<daysBetween.count {
            if daysBetween[i] == cell.cellTypeLabel.text {
                cell.backgroundCell.backgroundColor = K.Colors.separetor
                cell.dayLabel.textColor = K.Colors.balanceT
            }
        }
    }
    
    func makeTwo(n: Int) -> String {
        if n < 10 {
            return "0\(n)"
        } else {
            return "\(n)"
        }
    }
    
    @IBAction func goPressed(_ sender: UIButton) {
        
        if sender.tag == 0 {
            month = getMonthFrom(string: selectedFrom)
            year = getYearFrom(string: selectedFrom)
        } else {
            month = getMonthFrom(string: selectedTo)
            year = getYearFrom(string: selectedTo)
        }
        getDays()
        collectionView.reloadData()
        goButtonsTitle()
    }
    
    func goButtonsTitle() {
        
        var textStart = "Start"
        var leftStart = ""
        var rightStart = "▶︎"
        
        let textEnd = "End"
        var leftEnd = ""
        var rightEnd = "▶︎"
        
        if getYearFrom(string: selectedFrom) > year {
            textStart = "Start"
            leftStart = ""
            rightStart = " ▶︎"
        } else {
            textStart = "Start"
            leftStart = "◀︎ "
            rightStart = ""
        }
        
        if getYearFrom(string: selectedFrom) == year {
            if getMonthFrom(string: selectedFrom) > month {
                textStart = "Start"
                leftStart = ""
                rightStart = "▶︎"
            } else {
                textStart = "Start"
                leftStart = "◀︎"
                rightStart = ""
            }
        }
        
        if getYearFrom(string: selectedFrom) == getYearFrom(string: selectedTo) {
            if getMonthFrom(string: selectedFrom) == getMonthFrom(string: selectedTo) {

                toggleButton(b: endButton, hidden: true)
                textStart = "Selected"
            }
            
        }
        
        if getYearFrom(string: selectedTo) > year {
            leftEnd = ""
            rightEnd = " ▶︎"
        } else {
            leftEnd = "◀︎ "
            rightEnd = ""
        }
        
        if getYearFrom(string: selectedTo) == year {
            if getMonthFrom(string: selectedTo) > month {
                leftEnd = ""
                rightEnd = "▶︎"
            } else {
                leftEnd = "◀︎"
                rightEnd = ""
            }
        }
        
        startButton.setTitle(leftStart + " " + textStart + " " + rightStart, for: .normal)
        endButton.setTitle(leftEnd + " " + textEnd + " " + rightEnd, for: .normal)
        
    }
    
    func toggleButton(b: UIButton, hidden: Bool) {
        
        let deviceHeight = UIScreen.main.bounds.height
        if hidden {
            UIView.animate(withDuration: 0.3) {
                b.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, deviceHeight + 100, 0)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                b.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
            }
        }
        
    }
    
    var doneIsActive = false
    func doneButtonIsActive() {
        if selectedTo == "" || selectedFrom == "" {
            doneIsActive = false
            UIView.animate(withDuration: 0.3) {
                self.doneButton.alpha = 0.2
            }
        } else {
            doneIsActive = true
            UIView.animate(withDuration: 0.3) {
                self.doneButton.alpha = 1
            }
        }
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        if ifCustom == false {
            appData.filter.from = ""
            appData.filter.to = ""
            self.performSegue(withIdentifier: K.calendarClosed, sender: self)
        } else {
            let day = appData.filter.getDayFromString(s: selectedFrom)
            let month = appData.filter.getMonthFromString(s: selectedFrom)
            let year = appData.filter.getYearFromString(s: selectedFrom)
            let dayTo = appData.filter.getDayFromString(s: selectedTo)
            let monthTo = appData.filter.getMonthFromString(s: selectedTo)
            let yearTo = appData.filter.getYearFromString(s: selectedTo)
            if yearTo == year {
                selectedPeroud = "\(returnMonth(month)), \(day) → \(returnMonth(monthTo)), \(dayTo) of \(yearTo)"
            } else {
                selectedPeroud = "\(returnMonth(month)), \(day) of \(year) → \(returnMonth(monthTo)), \(dayTo) of \(yearTo)"
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        if doneIsActive {
            appData.filter.from = selectedFrom
            appData.filter.to = selectedTo
            self.performSegue(withIdentifier: K.calendarClosed, sender: self)
        }
    }
    
}


// collection
extension CalendarVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: K.collectionCell, for: indexPath) as! CVCell
        
        cell.setupCell()
        cell.dayLabel.text = "\(days[indexPath.row])"
        
        
        let dayCell = makeTwo(n: days[indexPath.row])
        let monthCell = makeTwo(n: month)
        let yearCell = makeTwo(n: year)
        
        cell.cellTypeLabel.text = "\(dayCell).\(monthCell).\(yearCell)"
        cellBackground(cell: cell)
        backgroundBetween(cell: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CVCell
        let dayCell = makeTwo(n: days[indexPath.row])
        let monthCell = makeTwo(n: month)
        let yearCell = makeTwo(n: year)
        
        if cell.cellTypeLabel.text == selectedFrom || cell.cellTypeLabel.text == selectedTo {
            removeSelected(cell: cell)
        } else {
            if selectedFrom == "" {
                selectedFrom = "\(dayCell).\(monthCell).\(yearCell)"
                selectedFromDayInt = indexPath.row + 1
            } else {
                selectedTo = "\(dayCell).\(monthCell).\(yearCell)"
                selectedToDayInt = indexPath.row + 1
            }
            ifToSmaller()
            
        }
        doneButtonIsActive()
        DispatchQueue.init(label: "reloadCollection").async {
            self.ifToSmaller()
            self.getBetweens()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
        if selectedFrom != "" {
            let text = "\(returnMonth((getMonthFrom(string: selectedFrom)))), \(getYearFrom(string: selectedFrom))"
            
            if textField.text == text {
                toggleButton(b: startButton, hidden: true)
            } else {
                toggleButton(b: startButton, hidden: false)
            }
        } else {
            toggleButton(b: startButton, hidden: true)
        }
        
        if selectedTo != "" {
            let text = "\(returnMonth((getMonthFrom(string: selectedTo)))), \(getYearFrom(string: selectedTo))"
            
            if textField.text == text {
                toggleButton(b: endButton, hidden: true)
            } else {
                toggleButton(b: endButton, hidden: false)
            }
        } else {
            toggleButton(b: endButton, hidden: true)
        }

        
    }
    
    
    
}

