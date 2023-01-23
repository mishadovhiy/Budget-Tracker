//
//  CalendarVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 08.10.2022.
//

import UIKit

class CalendarControlVC: UIViewController {

    @IBOutlet weak var monthView: TouchView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainBackgroundView: UIView!
    
    static var shared: CalendarControlVC?
    
    var years:(from:Int, to:Int) = (from:0,to:0)

    var tableData:[CalendarModel] = []
    var _middleDate:CalendarData?
    var dateSelected:((_ date:DateComponents)->())?
    var selectedDate:DateComponents?
    override func viewDidLoad() {
        super.viewDidLoad()
        CalendarControlVC.shared = self
        monthView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.monthPressed(_:))))
        let swipeClose = UISwipeGestureRecognizer(target: self, action: #selector(swipeClose(_:)))
        self.view.addGestureRecognizer(swipeClose)
        DispatchQueue.init(label: "l", qos: .userInitiated).async {
            let today = self.selectedDate ?? Date().toDateComponents()
            self.middleDate = .init(year: today.year ?? 0, month: today.month ?? 0)
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            //self.view.backgroundColor = K.Colors.Interface.pimaryBackground.withAlphaComponent(0.7)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .clear
        }
    }
    
    @objc func monthPressed(_ sender:UITapGestureRecognizer) {
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first?.view {
            if touch != mainBackgroundView {
                self.dismiss(animated: true)
            }
        }
    }
    
    var middleDate:CalendarData? {
        get {
            return _middleDate
        }
        set {
            _middleDate = newValue
            if let val = newValue {
                createCalendarData(val)
            }
        }
    }
    
    
    func newMonth(current:CalendarData, i:Int) -> CalendarData {
        let month = current.month + (i - 1)
        if month >= 1 && month <= 12 {
            return .init(year: current.year, month: month)
        } else {
            let minus = month < 1
            return .init(year: current.year + (minus ? (-1) : 1),
                         month: !minus ? 1 : 12)
        }
    }
    
    func createCalendarData(_ middle:CalendarData, animated:Bool = false) {
        var new:[CalendarModel] = []
        for i in 0..<3 {
            new.append(.init(self.newMonth(current: middle, i: i)))
        }
        self.tableData = new
        DispatchQueue.main.async {
            if self.collectionView.delegate == nil {
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
            }
            self.collectionView.scrollToItem(at: .init(item: 1, section: 0), at: .centeredHorizontally, animated: animated)
            self.monthLabel.text = "\(middle.month.stringMonth.capitalized) \(middle.year)"
            if !animated {
            self.collectionView.reloadData()
                //get middle date
            }
        }
        
    }
    

    
    func daySelected(_ day:Int) {
        if let action = dateSelected,
           let mid = middleDate
        {
            let dateComp = DateComponents(year: mid.year,
                                          month: mid.month,
                                          day: day)
            action(dateComp)
        }
    }
    
    func calendarMonthChanged(appeared:Bool, plus:Bool = true) {
        collectionView.scrollToItem(at: .init(item: !plus ? 0 : 2, section: 0), at: .centeredHorizontally, animated: true)
        
    }
    
    
    @IBAction func toggleMonth(_ sender: UIButton) {
        calendarMonthChanged(appeared: false, plus: !(sender.tag == 0))
        
    }
    
    @objc func swipeClose(_ sender:UISwipeGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    var selectedInt = 0
    private var scrollPos:Int = 0
    var waitDeclar = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scroll = scrollView.contentOffset.x
        let pos = getFromScroll(scroll)

        if pos != scrollPos {
            scrollPos = pos
        }
        
    }
    

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if waitDeclar {
            waitDeclar = false
            completeScrolling(scrollView.contentOffset.x)
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        waitDeclar = decelerate
        if !decelerate {
            completeScrolling(scrollView.contentOffset.x)
        }
        
    }

    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
   //     if scrolled {
            scrolled = false
            self.middleDate = .init(year: tableData[selectedInt].year,
                                    month: tableData[selectedInt].month)
        self.collectionView.reloadData()
            //get middle date
     //   }
    }
    
    
    
    func getFromScroll(_ position:CGFloat) -> Int {
        let cellWindth = self.collectionView.frame.width
        let pos = position + (cellWindth / 2)
        let selectedFloat = pos / cellWindth
        var selectedIntResult = Int(selectedFloat != 0 && selectedFloat < CGFloat(Int.max) ? selectedFloat : 50)
        
        if selectedIntResult <= tableData.count - 1 {
            selectedInt = selectedIntResult
        } else {
            selectedIntResult = selectedIntResult > 0 ? (tableData.count - 1) : selectedIntResult
            selectedInt = selectedIntResult
        }
        return selectedIntResult
    }
    
    private func completeScrolling(_ position:CGFloat) {
        let selected = getFromScroll(position)
        scrolled = true
        if selected <= tableData.count - 1 {
            collectionView.scrollToItem(at: .init(item: selected, section: 0), at: .centeredHorizontally, animated: true)
        } else {
            collectionView.scrollToItem(at: .init(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        }
        
    }
    
    var scrolled = false
}




extension CalendarControlVC {
    
    static func present(currentSelected:DateComponents? = nil, selected:@escaping (_ date:DateComponents)->()) {
        let storyboard = UIStoryboard(name: "Reusable", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CalendarControlVC") as! CalendarControlVC
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        vc.dateSelected = selected
        vc.selectedDate = currentSelected
     //   NavigationVC.shared?.present(vc, animated: true)
        
    }

}
