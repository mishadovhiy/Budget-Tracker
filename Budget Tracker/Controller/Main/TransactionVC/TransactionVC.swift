//
//  TransactionVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import AVFoundation

///bug:
//when quiting vc its refreshing on mainVC

var lastSelectedDate:String?

protocol TransitionVCProtocol {
    func addNewTransaction(value: String, category: String, date: String, comment: String, reminderTime:DateComponents?, repeated:Bool?)
    func editTransaction(_ transaction:TransactionsStruct, was:TransactionsStruct,reminderTime: DateComponents?, repeated: Bool?, idx:Int?)
    func quiteTransactionVC(reload:Bool)
    func deletePressed()
}

class TransitionVC: SuperViewController {
    @IBOutlet weak var removeLastButton: UIButton!
    @IBOutlet weak var removeAllButton: UIButton!
    @IBOutlet weak var cameraContainer: UIView!
    @IBAction func trashPressed(_ sender: UIButton) {
        donePressed = true
        print("trashPressedtrashPressedtrashPressed")
        DispatchQueue.main.async {
            self.dismissVC() {
                DispatchQueue.init(label: "reload").async {
                    self.delegate?.deletePressed()
                }
                
            }
        }
        
    }

    @IBOutlet weak var toggleCameraButton: TouchButton!
    
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var dateTextField: CustomTextField!
    @IBOutlet weak var categoryTextField: CustomTextField!
    @IBOutlet weak var purposeSwitcher: UISegmentedControl!
    @IBOutlet weak var showValueButton: UIButton!
    @IBOutlet weak var numbarPadView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var minusPlusLabel: UILabel!
    @IBOutlet weak var commentTextField: TextField!
    @IBOutlet weak var commentCountLabel: UILabel!
    var dismissTransitionHolder:AnimatedTransitioningManager?
    var delegate:TransitionVCProtocol?
    var reminder_Repeated:Bool?
    var reminder_Time:DateComponents?
    var selectedPurpose: Int?
    var paymentReminderAdding = false
    var pressedValue = "0"
    var editingDateHolder = ""
    var editingCategoryHolder = ""
    var editingValueHolder = 0.0
    var editingCommentHolder = ""
    
    var editingDate = ""
    var editingCategory = ""
    var editingValue = 0.0
    var editingComment = ""
    
    var pressedValueArrey: [String] =  []
    
    var dateSet:String?
    var dateChanged = false
    var sbvsloded = false
    var idxHolder:Int?
    var donePressed = false
    var selectedCategory: NewCategories?
    var fromDebts = false
    var enteringValueResult:Int {
        var res = "\(Int(cameraValue))"
        if editingValue != 0 {
            "\(Int(editingValue))".forEach {
                res.append($0)
            }
        }
        let val = (Int(res) ?? 0)
        return purposeSwitcher.selectedSegmentIndex == 0 ? (val * -1) : val
    }
    var cameraValue:Int = 0
    
    var calendarSelectedTime:DateComponents?
    func dismissVC(complation:(()->())? = nil) {
        self.navigationController?.delegate = dismissTransitionHolder
        
        if self.navigationController is TransactionNav {
            self.dismiss(animated: true, completion: complation)
            complation?()
            viewDidDismiss()
        } else {
            self.navigationController?.popViewController(animated: true)
            complation?()
            viewDidDismiss()
        }
    }
    var cameraVC:SelectTextImageContainerView?
    func createCameraContainer() {
        let vc = SelectTextImageContainerView.configure()
        let nav = UINavigationController(rootViewController: vc)
        addChild(nav)
        guard let childView = nav.view else {
            return
        }
        cameraContainer.addSubview(childView)
        childView.addConstaits([.left:0, .right:0, .top:0, .bottom:0], superV: cameraContainer)
        nav.didMove(toParent: self)
        vc.delegate = self
        nav.setBackground(.clear)
        cameraVC = vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        dismissTransitionHolder = self.navigationController?.delegate as? AnimatedTransitioningManager
        updateUI()
        purposeSwitcher.selectedSegmentIndex = 0
        purposeSwitched(purposeSwitcher)
        getEditingdata()

        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if !fromEdit {
            createCameraContainer()
            toggleCamera(show:fromEdit ? false : (AppDelegate.shared?.db.viewControllers.cameraStorage.addTransactionCameraEnabled ?? false), animated:false)

        } else {
            toggleCameraButton.isHidden = true
            cameraContainer.isHidden = true
        }

    }

    override func viewDidDismiss() {
        super.viewDidDismiss()
        dismissTransitionHolder = nil
        panMahanger = nil
     //   delegate = nil
        dateSet = nil
        cameraVC?.toggleCameraSession(pause: true, remove: true)
    }

    var panMahanger:PanViewController?

    lazy var defaultDate:String = {
        return dateSet ?? (lastSelectedDate ?? (AppDelegate.shared?.appData.filter.from ?? ""))
    }()
    @IBOutlet weak var doneButton: UIButton!

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !sbvsloded {
            sbvsloded = true
            dateTextField.inputView = UIView(frame: .zero)
            dateTextField.isUserInteractionEnabled = false
            dateTextField.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(datePressed)))
            commentTextField.addTarget(self, action: #selector(commentCount), for: .editingChanged)
            categoryTextField.isUserInteractionEnabled = false
            categoryTextField.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryPressed)))

            self.dateTextField.placeholder = defaultDate
            if editingDate == "" {
                displeyingTransaction.date = defaultDate
            }
            self.dateTextField.setPlaceHolderColor(K.Colors.textFieldPlaceholder)
            self.commentTextField.placeholder = "Short comment".localize
            self.commentTextField.setPlaceHolderColor(K.Colors.textFieldPlaceholder)

        }
    }
    
    
    func updateUI() {
        if paymentReminderAdding {
            self.repeatedView.isHidden = false
            self.repeateSwitch.isOn = (reminder_Repeated ?? false)
        }

        delegates(fields: [categoryTextField, dateTextField, commentTextField])
        pressedValue = "0"

        DispatchQueue.main.async {
                ///self.appData.objects.datePicker.datePickerMode = .date
            self.valueLabel.text = self.pressedValue
            
        }
    }
    
    @objc func datePressed(_ sender: UITapGestureRecognizer) {
        print("datePressed")
        let vc = CalendarVC.configure()
        vc.delegate = self
  //      vc.darkAppearence = true
        vc.selectedFrom = displeyingTransaction.date == "" ? self.defaultDate : displeyingTransaction.date

        if paymentReminderAdding {
            vc.datePickerDate = reminder_Time?.toIsoString() ?? ""
            vc.selectingDate = false
            vc.needPressDone = true
            vc.canSelectOnlyOne = true
        }
        self.navigationController?.delegate = nil
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func categoryPressed(_ sender: UITapGestureRecognizer) {
        print("toCategories")
        let vc = CategoriesVC.configure(type: .categories)
        vc.delegate = self
        vc.hideTitle = true
        self.navigationController?.delegate = nil
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func delegates(fields: [UITextField]) {
        for i in 0..<fields.count {
            fields[i].delegate = self
        }
    }
    
    @objc func commentCount() {
        
        DispatchQueue.main.async {
            self.commentCountLabel.text = "\(30 - (self.commentTextField.text?.count ?? 0))"
            if self.commentTextField.text?.count == 30 {
                self.commentCountLabel.textColor = K.Colors.negative
                UIImpactFeedbackGenerator().impactOccurred()
            } else {
                self.commentCountLabel.textColor = K.Colors.balanceT
            }
            if self.commentTextField.text?.count == 0 {
                UIView.animate(withDuration: 0.2) {
                    self.commentCountLabel.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.commentCountLabel.alpha = 1
                }
            }
        }
    }
    var fromEdit = false
    func getEditingdata() {
        /*var lastExpense: NewCategories {
            let all = Array(db.categories)
            for i in 0..<all.count {
                if all[i].purpose == .expense {
                    return all[i]
                }
            }
            return NewCategories(id: -1, name: "Uncategorized", icon: "", color: "", purpose: .expense)
        }
        selectedCategory = db.category(editingCategory) ?? lastExpense*/
        if editingCategory != "" {
            selectedCategory = DataBase().category(self.editingCategory)
            purposeSwitcher.selectedSegmentIndex = selectedPurpose != nil ? selectedPurpose! : 0
            purposeSwitched(purposeSwitcher)
            DispatchQueue.main.async {
                self.categoryTextField.text = self.selectedCategory?.name ?? "-"//self.editingCategory
            }
            
        }
        if editingDate != "" {
            fromEdit = true
            self.dateChanged = true
            displeyingTransaction.date = editingDate
            if editingValue > 0.0 {
                editingValueAmount(segment: 1, multiply: 1)
            } else {
                editingValueAmount(segment: 0, multiply: -1)
            }
          /*  if #available(iOS 13.0, *) {//desable close
                self.isModalInPresentation = true
            }*/
            minusPlusLabel.alpha = 1
            let db = DataBase()
            let category = db.category(self.editingCategory)
            selectedCategory = category
            DispatchQueue.main.async {
                self.categoryTextField.text = category?.name ?? "-"
                self.dateTextField.text = self.editingDate
                self.commentTextField.text = self.editingComment
            }
            editingCategoryHolder = editingCategory
            editingDateHolder = editingDate
            editingValueHolder = editingValue
            editingCommentHolder = editingComment
            DispatchQueue.main.async {
                if (self.commentTextField.text?.count ?? 0) > 0 {
                    self.commentCountLabel.text = "\(30 - (self.commentTextField.text?.count ?? 0))"
                    UIView.animate(withDuration: 0.2) {
                        self.commentCountLabel.alpha = 1
                    }
                }
                if !self.paymentReminderAdding {
                    self.trashButton.isHidden = false
                }
            }
        } else {
            displeyingTransaction.date = defaultDate
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = false
            }
        }
        
    }
    
    func editingValueAmount(segment: Int, multiply: Int) {
        
        self.purposeSwitcher.selectedSegmentIndex = segment
        self.purposeSwitched(self.purposeSwitcher)
        DispatchQueue.main.async {
            self.valueLabel.text = "\(Int(self.editingValue) * multiply)"
        }
        pressedValue = "\(Int(editingValue) * multiply)"
    }
    

    
    @IBOutlet weak var repeatedView: UIView!
    
    @IBAction func repeatedSwitched(_ sender: UISwitch) {
        DispatchQueue.main.async {
            self.reminder_Repeated = sender.isOn
        }
    }
    func checkDate(date:String, completion:(Bool)->()) {
        if idxHolder != nil {
            if let time = self.reminder_Time {
                var day =  date.stringToCompIso()
                day.hour = time.hour
                day.minute = time.minute
                day.second = time.second
                if !day.expired {
                    completion(true)
                } else {
                    DispatchQueue.main.async {
                        self.newMessage?.show(title:"Day can't be older than today".localize, type: .error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.newMessage?.show(title:"Set reminder date".localize, type: .error)
                }
            }
        } else {
            completion(true)
        }
        
    }
    private func quite() {
        DispatchQueue.main.async {
            self.dismissVC()
        }
    }
    func addNew(value: String, category: String, date: String, comment: String) {
        donePressed = true
        print("addNew called", value)
        print("isEditing ", editingDate)
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
            self.checkDate(date: date) { _ in
                DispatchQueue.init(label: "download").async {
                if self.editingDate != "" {
                    let new = TransactionsStruct(value: value, categoryID: category, date: date, comment: comment)
                    let was = TransactionsStruct(value: "\(self.editingValueHolder)", categoryID: self.editingCategory, date: self.editingDate, comment: self.editingComment)
                    self.delegate?.editTransaction(new, was: was, reminderTime: self.reminder_Time, repeated: self.reminder_Repeated, idx: self.idxHolder)
                    self.quite()

                    
                } else {
                    if self.paymentReminderAdding {
                        let time = self.reminder_Time
                        let dateCo = time?.createDateComp(date: date, time: time)
                        if dateCo?.expired ?? true {
                            DispatchQueue.main.async {
                                self.newMessage?.show(title:"Wrong date", type: .error)
                            }
                        } else {
                            self.quite()

                            self.delegate?.addNewTransaction(value: value, category: category, date: date, comment: comment, reminderTime: self.reminder_Time, repeated: self.reminder_Repeated)
                        }
                    } else {
                        self.quite()
                        self.delegate?.addNewTransaction(value: value, category: category, date: date, comment: comment, reminderTime: self.reminder_Time, repeated: self.reminder_Repeated)
                    }
                
                }
                }
                
            }
            
        }
    }
    
    
    @objc func valueLabelColor() {
        valueLabel.textColor = K.Colors.category
        minusPlusLabel.textColor = K.Colors.category
    }
    

    var displeyingTransaction = TransactionsStruct(value: "0", categoryID: "", date: "", comment: "")
    
    @IBOutlet weak var repeateSwitch: UISwitch!
    @IBAction func donePressed(_ sender: UIButton) {
        let newDate = self.displeyingTransaction.date == "" ? defaultDate : self.displeyingTransaction.date
        print("newDate:", newDate)
        print("egrfwd ", self.displeyingTransaction.date)
        if let category = selectedCategory {
            DispatchQueue.main.async {
                if self.valueLabel.text != "0" {
                    let value = "\(self.enteringValueResult)"
                    let comment = self.commentTextField.text ?? ""
                    self.addNew(value: value, category: "\(category.id)", date: newDate, comment: comment)
                } else {
                    self.errorSaving()
                }
            }
        }
        
    }
    
    var enteringValueGet:Int {
        let intValue = (Double(self.valueLabel.text ?? "") ?? 0.0) * (-1)
        let value = purposeSwitcher.selectedSegmentIndex == 0 ? Int(intValue) : Int(self.valueLabel.text ?? "")
        return value ?? 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if self.commentTextField.isFirstResponder {
            self.commentTextField.endEditing(true)
            toggleAmountKeyboard(show: true)
        }
    }
    
    func errorSaving() {
        var wasHidden = false
        let bounds = valueLabel.bounds
        if minusPlusLabel.alpha == 0 {
            wasHidden = true
            minusPlusLabel.alpha = 0
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            self.valueLabel.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width + 10, height: bounds.size.height)
        }) { (success:Bool) in
            if success {
                UIView.animate(withDuration: 0.5, animations: {
                    self.valueLabel.bounds = bounds
                })
                if wasHidden == false {
                    self.minusPlusLabel.alpha = 1
                }}
        }
        UIImpactFeedbackGenerator().impactOccurred()
        valueLabel.textColor = K.Colors.negative
        minusPlusLabel.textColor = K.Colors.negative
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(valueLabelColor), userInfo: nil, repeats: false)
        
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismissVC() {
                DispatchQueue.init(label: "reload").async {
                    if self.editingDate != "" {
                        self.delegate?.quiteTransactionVC(reload: false)
                    }
                }
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        if !(navigationController is TransactionNav) {
            AppDelegate.shared?.banner.hide(ios13Hide:true)
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !(navigationController is TransactionNav) && !(self.navigationController?.viewControllers.contains(where: {$0 is TransitionVC}) ?? false) {
            AppDelegate.shared?.banner.appeare(force:true)
        }
    }
    
    var viewAppeareCalled = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !viewAppeareCalled {
            viewAppeareCalled = true
            self.cameraVC?.toggleCameraSession(pause: fromEdit ? true : !(AppDelegate.shared?.db.viewControllers.cameraStorage.addTransactionCameraEnabled ?? false))

        }
        if !(navigationController is TransactionNav) && panMahanger == nil {
            panMahanger = .init(vc: self, toView: valueLabel.superview?.superview, dismissAction: {
                self.navigationController?.delegate = self.dismissTransitionHolder
            })
            panMahanger?.canSwipeFromFull = false
        } else {
            
        }

     //   purposeSwitcher.tintColor = K.Colors.category
    }
    @IBAction func purposeSwitched(_ sender: UISegmentedControl) {
        var placeHolder = ""
        if !fromDebts {
            DispatchQueue.main.async {
                self.categoryTextField.text = ""
            }
            let lastSelectedID = appData.lastSelected.gett(valueType: sender.selectedSegmentIndex == 0 ? .expense : .income)
            if let cat = db.category(lastSelectedID ?? "") {
                selectedCategory = cat
                print("last selected cat: ", cat.name)
                placeHolder = cat.name
            } else {
                let defCat = db.categories.first ?? NewCategories(id: -1, name: "Unknown".localize, icon: "", color: "", purpose: sender.selectedSegmentIndex == 0 ? .expense : .income)
                selectedCategory = defCat
                placeHolder = defCat.name
            }
        }
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            DispatchQueue.main.async {
                self.minusPlusLabel.text = "-"
            }

            showPadPressed(showValueButton)
            
        case 1:
            DispatchQueue.main.async {
                self.minusPlusLabel.text = "+"
            }

            showPadPressed(showValueButton)
            
        default:
            placeHolder = ""
        }
        
        DispatchQueue.main.async {
            self.categoryTextField.placeholder = placeHolder
        }
    }
    func toggleAmountKeyboard(show:Bool) {
        if show {
            self.categoryTextField.endEditing(true)
            self.commentTextField.endEditing(true)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.numbarPadView.alpha = show ? 1 : 0
        }
    }
    
    @IBAction func showPadPressed(_ sender: UIButton) {
        toggleAmountKeyboard(show: true)
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        if pressedValue == "0" {
            pressedValue = ""
        }
        if pressedValue.count != 7 {
            AudioServicesPlaySystemSound(1104)
            pressedValue = pressedValue + (sender.currentTitle ?? "")
            if pressedValue != "0" {
                minusPlusLabel.alpha = 1
            }
        } else {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        editingValue = Double(pressedValue) ?? 0
        DispatchQueue.main.async {
            self.valueLabel.text = "\(self.enteringValueResult)"
        }
        
        
    }
    
    @IBAction func erasePressed(_ sender: UIButton) {

        if sender.tag == 1 {
            AudioServicesPlaySystemSound(1155)
            if pressedValue.count > 0 {
                pressedValue.removeLast()
                
            }
            if pressedValue.count == 0 {
                pressedValue.removeAll()
                minusPlusLabel.alpha = 0
            }
        }
        if sender.tag == 2 {
            AudioServicesPlaySystemSound(1156)
            pressedValue.removeAll()
            minusPlusLabel.alpha = 0
        }
        editingValue = Double(pressedValue) ?? 0
        
        DispatchQueue.main.async {
            self.valueLabel.text = "\(self.enteringValueResult)"//from sfeafeds
        }
    }
    

    var cameraShowing:Bool = false
    private func toggleCamera(show:Bool, animated:Bool = true) {
        cameraShowing = show
        let hide = cameraContainer.frame.height + view.safeAreaInsets.bottom
        DispatchQueue(label: "db", qos: .userInitiated).async {
            AppDelegate.shared?.db.viewControllers.cameraStorage.addTransactionCameraEnabled = show
        }
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.3) {
            self.cameraContainer.layer.move(.top, value: show ? 0 : hide)
        } completion: { _ in
            if #available(iOS 13.0, *) {
                self.toggleCameraButton.fadeTransition(0.1)
                self.toggleCameraButton.setImage(show ? .init(named: "closeNoBack") : .init(systemName: "camera.fill"), for:.normal)
            }
        }

        cameraVC?.toggleCameraSession(pause: !show)
        
        
    }
    
    @IBAction func toggleCameraPressed(_ sender: Any) {
        toggleCamera(show: !cameraShowing)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        DispatchQueue.main.async {
            self.showPadPressed(self.showValueButton)
        }
    }
}


//MARK: - TableView



//MARK: - TextField

extension TransitionVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.numbarPadView.alpha = 0
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 30
    }
    
    
    
}


//MARK: - Custom Text Field

class CustomTextField: UITextField {
    
    var enableLongPressActions = false
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return enableLongPressActions
    }
    
    override var placeholder: String? {
        get { return super.placeholder }
        set {
            super.placeholder = newValue
            DispatchQueue.main.async {
                self.attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: [NSAttributedString.Key.foregroundColor: K.Colors.textFieldPlaceholder])
            }

        }
    }
}

extension TransitionVC: CalendarVCProtocol {
    func dateSelected(date: String, time: DateComponents?) {
        reminder_Time = time
        calendarSelectedTime = time
        dateChanged = true
        let compDate = date.stringToCompIso()
        let newDate = compDate.toShortString() ?? date
        let timeString = paymentReminderAdding ? (", " + (time?.timeString ?? "")) : ""
        DispatchQueue.main.async {
            self.dateTextField.text = newDate + timeString
        }
        lastSelectedDate = newDate
        displeyingTransaction.date = newDate
        print(displeyingTransaction.date, " newDatenewDatenewDate")
        print(time, " timetimetimetimetimetime")

    }
    
    
}

extension TransitionVC: CategoriesVCProtocol {
    
    func categorySelected(category: NewCategories?, fromDebts: Bool, amount: Int) {
        if let category = category {
            print("categorySelectedtransactionsvc", category)
            self.fromDebts = fromDebts
            if !fromDebts {
                purposeSwitcher.selectedSegmentIndex = category.purpose == .expense ? 0 : 1
                purposeSwitched(purposeSwitcher)
                DispatchQueue(label: "db", qos: .userInitiated).async {
                    switch category.purpose {
                    case .expense:
                        self.appData.lastSelected.sett(value: "\(category.id)", valueType: .expense)
                    case .income:
                        self.appData.lastSelected.sett(value: "\(category.id)", valueType: .income)
                    case .debt:
                        self.appData.lastSelected.sett(value: "\(category.id)", valueType: .debt)

                    }
                }
            } else {
                DispatchQueue(label: "db", qos: .userInitiated).async {
                    self.appData.lastSelected.sett(value: "\(category.id)", valueType: .debt)
                    self.selectedCategory = category
                    DispatchQueue.main.async {
                        
                        if self.pressedValue == "" || self.pressedValue == "0" {
                        }
                       // self.valueLabel.text = "\(amount < 0 ? amount * (-1) : amount)"
                     //   self.minusPlusLabel.alpha = 1
                       // self.purposeSwitcher.selectedSegmentIndex = amount * (-1) < 0 ? 0 : 1
                      //  self.purposeSwitched(self.purposeSwitcher)
                        
                        let selectedSeg = self.purposeSwitcher.selectedSegmentIndex
                        let value = selectedSeg == 0 ? "\(Double(self.valueLabel.text ?? "") ?? 0.0)" : self.valueLabel.text ?? ""
                        print(amount, "resultresultresultresult")
                        print(selectedSeg)
                        print(value, "selectedSegselectedSegselectedSeg")
                        
                    }
                }
            }
            selectedCategory = category
            DispatchQueue.main.async {
                self.categoryTextField.text = category.name
            }
        }
        
    }
    
    
    
}


extension TransitionVC:SelectTextImageContainerViewProtocol {
    func totalChanged(_ total: Int) {
        print(total, " brgefwdas")
        cameraValue = total
        valueLabel.text = "\(enteringValueResult)"
    }
    
    
}


extension TransitionVC {
    static func configure() -> TransitionVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TransitionVC") as! TransitionVC
        return vc
    }
}
