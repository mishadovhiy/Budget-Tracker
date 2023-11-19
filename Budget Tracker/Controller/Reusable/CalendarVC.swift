//
//  CalendarVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 22.04.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

protocol CalendarVCProtocol {
    func dateSelected(date: String, time: DateComponents?)
}

class CalendarVC: SuperViewController {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarContainerView: UIView!
    //@IBOutlet weak var commentTextField: UITextField!
    //  @IBOutlet weak var reminderTimeLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var mainDescriptionLabel: UILabel!
    @IBOutlet weak var mainTitleLabel: UILabel!
    
    var vcHeaderData: headerData?
    
    @IBOutlet weak var headerView: UIView!
   // @IBOutlet weak var textField: UITextField!
    
//    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var doneButton: UIButton!
    

    var delegate: CalendarVCProtocol?
    var canSelectOnlyOne = false
    var selectedFrom = ""
    var selectedTo = ""
    var days = [0]
    var daysBetween = [""]
    var selectedFromDayInt = 0
    var selectedToDayInt = 0
  //  var darkAppearence = false
    var needPressDone = false
    
    var year = 1996
    var month = 11
    
    @objc func dateSelected(_ sender: UIDatePicker) {
        print(sender.date)
    }
    @IBOutlet weak var closeButton: UIButton!
    
    var datePickerDate: String?
    var svsLoaded = false
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !svsLoaded {
            svsLoaded = true

        let height = self.view.frame.height
        startButton.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, height + self.startButton.layer.frame.height, 0)
        endButton.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, height + self.endButton.layer.frame.height, 0)
//        textField.layer.masksToBounds = true
//        textField.layer.cornerRadius = 5
//            textField.setPaddings(5)
        }
    }
    
    
    var calendarVC:CalendarControlVC?
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedFrom, " gterg4")
        let date = self.dateFrom(sting: self.selectedFrom)?.toDateComponents()
        calendarVC = createCalendar(calendarContainerView, currentSelected: date, selected: self.dateSelectedContainer(_:))
        calendarVC?.monthChanged = { year, month in
          //  let date = self.dateFrom(sting: "0.\(month.makeTwo()).\(year)")
            DispatchQueue.main.async {
                self.monthLabel.text = month.stringMonth + ", \(year)"
            }
        }
        calendarVC?.higlightSelected = true
        self.monthLabel.text = date == nil ? "" : (date?.month?.stringMonth ?? "-") + ", \(date?.year ?? 0)"
        if let pickerDate = datePickerDate {
            timePicker.alpha = 1
            timePicker.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)
            if datePickerDate != "" {
                let comp = DateComponents()
                let dateCo = comp.stringToCompIso(s: pickerDate)
                if let date = Calendar.current.date(from: dateCo) {
                    timePicker.date = date
                }
                
                timePicker.setValue(K.Colors.category, forKeyPath: "textColor")
            }
            
        } else {
            timePicker.alpha = 0
        }

        if vcHeaderData != nil {
            DispatchQueue.main.async {
                if self.vcHeaderData?.title != "" {
                    self.mainTitleLabel.text = self.vcHeaderData?.title
                }
                if (self.vcHeaderData?.description ?? "") != "" {
                    self.mainDescriptionLabel.text = self.vcHeaderData?.description
                }
                self.mainDescriptionLabel.isHidden = self.vcHeaderData?.description ?? "" == ""
                
            }
        }
        
        updaiteUI()
    }



    override func viewWillAppear(_ animated: Bool) {
        var hideNav:Bool {
            if delegate != nil {
                return false
            } else {
                return true
            }
        }
        self.navigationController?.setNavigationBarHidden(hideNav, animated: false)
        self.title = "Calendar".localize
        self.headerView.isHidden = self.vcHeaderData == nil
        bannerWasHidden = AppDelegate.shared?.banner.adHidden ?? false
        AppDelegate.shared?.banner.hide(ios13Hide:true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !bannerWasHidden {
            AppDelegate.shared?.banner.appeare(force: true)
        }
    }
    var bannerWasHidden = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if delegate == nil {
            if ifCustom {
                if AppDelegate.shared?.appData.filter.from != AppDelegate.shared?.appData.filter.to {
                    selectedFrom = AppDelegate.shared?.appData.filter.from ?? ""
                    selectedTo = AppDelegate.shared?.appData.filter.to ?? ""
                    print(selectedTo, "selectedToselectedToselectedTo")
                    selectedFromDayInt = AppDelegate.shared?.appData.filter.getDayFromString(s: selectedFrom) ?? 0
                    selectedToDayInt = AppDelegate.shared?.appData.filter.getDayFromString(s: selectedTo) ?? 0
                    ifToSmaller()
                    
                    year = getYearFrom(string: selectedFrom)
                    month = getMonthFrom(string: selectedFrom)
                    getDays()
                    getBetweens()
                    doneIsActive = true
                    doneButtonIsActive()
                    ifEndInvisible()

         /*           DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }*/
                } else {
                    selectedFrom = AppDelegate.shared?.appData.filter.from ?? ""
                    year = getYearFrom(string: selectedFrom)
                    month = getMonthFrom(string: selectedFrom)
                    getDays()
                    doneIsActive = true
                    doneButtonIsActive()
                    ifEndInvisible()
//                    DispatchQueue.main.async {
//                        self.collectionView.reloadData()
//                    }
                }
                
                
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
    
    let today = AppDelegate.shared?.appData.filter.getToday() ?? ""
    func updaiteUI() {
//        collectionView.delegate = self
//        collectionView.dataSource = self
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeForward))
        swipeLeft.direction = .left;
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeBack))
        swipeRight.direction = .right;
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)

        print(selectedFrom, "selectedFromselectedFromselectedFromselectedFrom")
        let data = AppDelegate.shared?.appData ?? .init()
        year = data.filter.getYearFromString(s: selectedFrom == "" ? today : selectedFrom)
        month = data.filter.getMonthFromString(s: selectedFrom == "" ? today : selectedFrom)
        getDays()
        doneButtonIsActive()

    }
    
    var daystoWeekStart = 0
    func getDays() {
        daystoWeekStart = 0
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        days.removeAll()

        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let strDate = "\(year)-\(AppData.makeTwo(n: month))-02"
        let datee = formatter.date(from: strDate)
        let calendarr = Calendar(identifier: .gregorian)
        let weekNumber = calendarr.component(.weekday, from: datee ?? Date())-3
        
        let weekRes = weekNumber < 0 ? 7 + weekNumber : weekNumber
        for _ in 0..<weekRes{
            daystoWeekStart += 1
            days.append(0)
        }
        for i in 0..<numDays {
            days.append(i+1)
        }
//        DispatchQueue.main.async {
//            self.textField.text = "\(self.returnMonth(self.month)), \(self.year)"
//        }
        
        
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
    
    /*ovverrideTest func returnMonth(_ month: Int) -> String {
        let monthes = [
            1: "Jan", 2: "Feb", 3: "Mar", 4: "Apr", 5: "May", 6: "Jun",
            7: "Jul", 8: "Aug", 9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec"
        ]
        return monthes[month] ?? "Jan"
    }*/
    
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
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
        
        if selectedFrom != "" || selectedTo != "" {
            goButtonsTitle()
        }
    }
    
    
    @IBAction func swipeForward(gestureRecognizer:UISwipeGestureRecognizer) {
        
        month = month + 1
        setYear()
        getDays()
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
//        
        if selectedFrom != "" || selectedTo != "" {
            goButtonsTitle()
        }
    }
    
    @IBAction func swipeBack(gestureRecognizer:UISwipeGestureRecognizer) {
        
        month = month - 1
        setYear()
        getDays()
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
        
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
    
    func removeSelected(cellType: String) {
        DispatchQueue.main.async {
            if self.selectedTo == cellType {
                self.selectedTo = ""
                self.selectedToDayInt = 0
            }
            if self.selectedFrom == cellType {
                if self.selectedTo != "" {
                    self.selectedFrom = self.selectedTo
                    self.selectedFromDayInt = self.selectedToDayInt
                    self.selectedTo = ""
                    self.selectedToDayInt = 0
                } else {
                    self.selectedFrom = ""
                    self.selectedFromDayInt = 0
                }
                /*self.selectedTo = ""
                self.selectedToDayInt = 0
                self.selectedFrom = ""
                self.selectedFromDayInt = 0*/
            }
        }
    }
    

    func dateFrom(sting: String) -> Date? {
        print("dateFrom", sting)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = .init(identifier: "en_US")
        dateFormatter.timeZone = .init(identifier: "America/New_York")
        let date = dateFormatter.date(from: sting)
        
        print("datedatedate", date)

        return date
    }
    
    func getBetweens() {
        daysBetween.removeAll()
        if selectedFrom != "" && selectedTo != "" {
            print("daysBetween from:", selectedFrom)
            print("daysBetween to:", selectedTo)
            
            if getYearFrom(string: selectedTo) == getYearFrom(string: selectedFrom) && (getMonthFrom(string: selectedTo) == getMonthFrom(string: selectedFrom)) {
                
                let dayFrom = AppDelegate.shared?.appData.filter.getDayFromString(s: selectedFrom) ?? 0
                print(dayFrom, "dayFromdayFromdayFromdayFromdayFrom")
                let dayTo = AppDelegate.shared?.appData.filter.getDayFromString(s: selectedTo) ?? 0
                let between = (dayTo - dayFrom) - 1
                var start = dayFrom + daystoWeekStart
                for _ in 0..<between {
                    let dayCell = AppData.makeTwo(n: days[start])
                    let monthCell = AppData.makeTwo(n: month)
                    let yearCell = AppData.makeTwo(n: year)
                    let new = "\(dayCell).\(monthCell).\(yearCell)"
                    daysBetween.append(new)
                    start += 1
                }
                
            } else {
               // allDaysBetween()
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
            let new: String = "\(AppData.makeTwo(n: dayA)).\(AppData.makeTwo(n: monthA)).\(AppData.makeTwo(n: yearA))"
            if new == selectedTo {
                break
            }
            daysBetween.append(new)
        }
    }
    
    
    func cellBackground(cell: CVCell) {
        DispatchQueue.main.async {
            if self.selectedTo == cell.cellTypeLabel.text || self.selectedFrom == cell.cellTypeLabel.text {
                cell.backgroundCell.backgroundColor = K.Colors.link
                cell.dayLabel.textColor = UIColor.white
            }else {
                let viewColor = self.view.backgroundColor
                cell.backgroundCell.backgroundColor = viewColor//self.darkAppearence ? UIColor(named: "darkTableColor") : K.Colors.background
                cell.dayLabel.textColor = viewColor//self.darkAppearence ? K.Colors.category : UIColor(named: "darkTableColor")
            }
        }
        
        
        
    }
    
    func backgroundBetween(cell: CVCell) {
        
        for i in 0..<daysBetween.count {
            DispatchQueue.main.async {
                if self.daysBetween[i] == cell.cellTypeLabel.text {
                    cell.backgroundCell.backgroundColor = K.Colors.separetor
                    cell.dayLabel.textColor = K.Colors.balanceT
                }
            }
        }
    }
    
/*ovverrideTestfunc makeTwo(n: Int) -> String {
        if n < 10 {
            return "0\(n)"
        } else {
            return "\(n)"
        }
    }*/
    
    @IBAction func goPressed(_ sender: UIButton) {
        
        if sender.tag == 0 {
            month = getMonthFrom(string: selectedFrom)
            year = getYearFrom(string: selectedFrom)
        } else {
            month = getMonthFrom(string: selectedTo)
            year = getYearFrom(string: selectedTo)
        }
        getDays()
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
        
        goButtonsTitle()
    }
    
    func goButtonsTitle() {
        
        let strStart = "Start".localize
        let strEnd = "End".localize
        
        
        var textStart = strStart
        var leftStart = ""
        var rightStart = "▶︎"
        
        let textEnd = strEnd
        var leftEnd = ""
        var rightEnd = "▶︎"
        
        if getYearFrom(string: selectedFrom) > year {
            textStart = strStart
            leftStart = ""
            rightStart = " ▶︎"
        } else {
            textStart = strStart
            leftStart = "◀︎ "
            rightStart = ""
        }
        
        if getYearFrom(string: selectedFrom) == year {
            if getMonthFrom(string: selectedFrom) > month {
                textStart = strStart
                leftStart = ""
                rightStart = "▶︎"
            } else {
                textStart = strStart
                leftStart = "◀︎"
                rightStart = ""
            }
        }
        
        if getYearFrom(string: selectedFrom) == getYearFrom(string: selectedTo) {
            if getMonthFrom(string: selectedFrom) == getMonthFrom(string: selectedTo) {

                toggleButton(b: endButton, hidden: true)
                textStart = "Selected".localize
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
    
    func toggleButton(b: UIButton, hidden: Bool, animation: Bool = true) {
        
        DispatchQueue.main.async {
            let deviceHeight = self.view.frame.height
            if hidden {
                UIView.animate(withDuration: animation ? 0.3 : 0.0) {
                    b.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, deviceHeight + b.frame.height, 0)
                }
            } else {
                UIView.animate(withDuration: animation ? 0.3 : 0.0) {
                    b.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0)
                }
            }
        }
        
    }
    
    var doneIsActive = false
    func doneButtonIsActive() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.doneButton.alpha = self.selectedFrom == ""  ? 0.2 : 1
                self.doneIsActive = self.selectedFrom == "" ? false : true
            }
        }
    }
    
    //here
    var selectingDate = true
    @IBAction func closePressed(_ sender: UIButton) {
        if !selectingDate {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    
                }
            }
        } else {
            if ifCustom == false {
                AppDelegate.shared?.appData.filter.from = ""
                AppDelegate.shared?.appData.filter.to = ""
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: K.calendarClosed, sender: self)
                }
                
            } else {
                let data = AppDelegate.shared?.appData ?? .init()
                let day = data.filter.getDayFromString(s: selectedFrom)
                let month = data.filter.getMonthFromString(s: selectedFrom)
                let year = data.filter.getYearFromString(s: selectedFrom)
                let dayTo = data.filter.getDayFromString(s: selectedTo)
                let monthTo = data.filter.getMonthFromString(s: selectedTo)
                let yearTo = data.filter.getYearFromString(s: selectedTo)
                let strOf = "of".localize
                if yearTo == year {
                    AppDelegate.shared?.appData.filter.selectedPeroud = "\(getMonth(month)), \(day) → \(getMonth(monthTo)), \(dayTo) \(strOf) \(yearTo)"
                } else {
                    AppDelegate.shared?.appData.filter.selectedPeroud = "\(getMonth(month)), \(day) \(strOf) \(year) → \(getMonth(monthTo)), \(dayTo) \(strOf) \(yearTo)"
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    var showTimePicker = false
    @IBAction func donePressed(_ sender: UIButton) {
        if delegate == nil {
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            if doneIsActive {
                AppDelegate.shared?.appData.filter.from = selectedFrom == "" ? selectedTo : selectedFrom
                AppDelegate.shared?.appData.filter.to = selectedTo == "" ? selectedFrom : selectedTo
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: K.calendarClosed, sender: self)
                }
               
            }
        } else {

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self.timePicker.date)
            DispatchQueue.main.async {
                if self.navigationController?.isNavigationBarHidden ?? true {
                    self.dismiss(animated: true) {
                        self.delegate?.dateSelected(date: self.selectedFrom, time: components)
                    }
                } else {
                    self.delegate?.dateSelected(date: self.selectedFrom, time: components)
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
        
    }
    
    
    
    var upToFour = (0,0)
    
    func containdInBetween(date: String) -> Bool {
        print(daysBetween, "daysBetweendaysBetweendaysBetweendaysBetween")
        var result = false
        for i in 0..<self.daysBetween.count {
            if self.daysBetween[i] == date {
                result = true
                //break
            }
        }
        //не добавлять дни между а просто считать больше чем "с" и меньше ли "по"
        return result
    }
    
    func dateSelectedContainer(_ date:DateComponents) {
        let dayCell = date.day?.makeTwo() ?? "-"
        let monthCell = date.month?.makeTwo() ?? "-"
        let yearCell = date.year?.makeTwo() ?? "-"
        let newSelected = "\(dayCell).\(monthCell).\(yearCell)"
        if needPressDone {
            if newSelected == selectedFrom || newSelected == selectedTo {
                removeSelected(cellType: newSelected)
            } else {
                if selectedFrom == "" {
                    selectedFrom = newSelected
                    selectedFromDayInt = date.day ?? 0
                } else {
                    if canSelectOnlyOne {
                        selectedFrom = newSelected
                        selectedFromDayInt = date.day ?? 0
                    } else {
                        selectedTo = newSelected
                        selectedToDayInt = date.day ?? 0
                    }
                    
                }
                ifToSmaller()
            }
            doneButtonIsActive()
            DispatchQueue.init(label: "reloadCollection").async {
                self.ifToSmaller()
                if self.selectedFrom != "" && self.selectedTo != "" {
                    let dateFromm = self.dateFrom(sting: self.selectedFrom) ?? Date()
                    let dateTo = self.dateFrom(sting: self.selectedTo) ?? Date()
                    if dateFromm > dateTo {
                        let toHolder = (self.selectedTo, self.selectedToDayInt)
                        self.selectedTo = self.selectedFrom
                        self.selectedToDayInt = self.selectedFromDayInt
                        self.selectedFrom = toHolder.0
                        self.selectedFromDayInt = toHolder.1
                        self.getBetweens()
                    } else {
                        self.getBetweens()
                    }
                } else {
                    self.getBetweens()
                }
                
                
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
            }
        } else if delegate != nil && !needPressDone {
            delegate?.dateSelected(date: newSelected, time: nil)
            navigationController?.popToRootViewController(animated: true)
        } else {
            delegate?.dateSelected(date: newSelected, time: nil)
        }
    }

    
}


extension CalendarVC {
    static func configure() -> CalendarVC {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
        return vc
    }
}

