//
//  UnsendedDataVC.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 22.01.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

protocol UnsendedDataVCProtocol {
    func quiteUnsendedData(deletePressed: Bool, sendPressed: Bool)
}

class UnsendedDataVC: SuperViewController {

    @IBOutlet weak var proView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var cornerButtons: [UIButton]!
    @IBOutlet weak var deleteSelectedButton: UIButton!
    @IBOutlet weak var saveAllButton: UIButton!
    var _tablTrans: [UnsendedTransactions] = []
    var categoruesTableData: [UnsendedCategories] = []
    var debtsTableData: [UnsendedDebts] = []
    var tableDataTransactions: [UnsendedTransactions] {
        get{
            return _tablTrans
        }
        set {
            _tablTrans = newValue
            print("table data new value setted")
            DispatchQueue.main.async {
                let prevUsername = UserDefaults.standard.value(forKey: "prevUserName") as? String ?? ""
                self.mainTitleLabel.text = "Data from \(prevUsername != "" ? prevUsername : "previous account")"
                //self.mainTitleLabel.font = .systemFont(ofSize: prevUsername.count > 2 ? 15 : 23, weight: .semibold)
                self.deleteSelectedButton.setTitle("Delete (\(self.selectedCount))", for: .normal)
                self.tableView.reloadData()
                if newValue.count == 0 && self.categoruesTableData.count == 0 && self.debtsTableData.count == 0 {
                    self.deletePress = true
                    self.dismiss(animated: true) {
                        self.delegate?.quiteUnsendedData(deletePressed: true, sendPressed: false)
                    }
                }
                UIView.animate(withDuration: 0.23) {
                    self.saveAllButton.alpha = self.selectedCount == 0 ? 1 : 0.2
                } completion: { (_) in
                }

            }
        }
    }
    
    @IBOutlet weak var deleteAllButton: UIButton!
    var transactions: [TransactionsStruct] = []
    var categories: [CategoriesStruct] = []
    var debts: [DebtsStruct] = []
    var delegate:UnsendedDataVCProtocol?
    
    struct UnsendedTransactions {
        let value: String
        let category: String
        let date: String
        let comment: String
        var selected: Bool
    }
    struct UnsendedCategories {
        let name: String
        let purpose: String
        var selected: Bool
    }
    struct UnsendedDebts {
        let name: String
        let amountToPay: String
        let dueDate: String
        var selected: Bool
    }
    
    var messageText = ""

    
    var didapp = false
    let activity = UIActivityIndicatorView(frame: .zero)
    //let proView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()

       // firstSectionHeight = self.view.frame.height - 200
        self.tableView.delegate = self
        self.tableView.dataSource = self

        for button in cornerButtons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 4
        }
        didapp = true
        
        
        
        DispatchQueue.main.async {
            
            self.proView.layer.cornerRadius = 6
            self.proView.subviews.first?.layer.masksToBounds = true
            self.proView.subviews.first?.layer.cornerRadius = 4
            let titleFrame = self.mainTitleLabel.frame
            //self.activity.frame = CGRect(x: titleFrame.maxX, y: titleFrame.minY + (self.mainTitleLabel.superview?.superview?.frame.minY ?? 0) + 6, width: 15, height: 15)
            self.activity.frame = CGRect(x: titleFrame.maxX + 17, y: 8 + (self.mainTitleLabel.superview?.frame.minY ?? 0) + (self.mainTitleLabel.superview?.superview?.frame.minY ?? 0), width: 15, height: 15)
            self.view.addSubview(self.activity)
            self.activity.style = .gray
            self.activity.startAnimating()
            self.deleteSelectedButton.superview?.alpha = 0
            self.deleteAllButton.alpha = 0
            //appData.proVersion = false
            
        }
        self.togglePurchaseButton()
        
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    
    func togglePurchaseButton(hideWithAnimation: Bool = false) {
        let selfBtn = self.saveAllButton.layer.frame
        let proLabel = UILabel(frame: CGRect(x: selfBtn.width - 40, y: -5, width: 30, height: 18))

        if !appData.proTrial && !appData.proVersion {
           // fatalError()
          //  self.proView.removeFromSuperview()
            self.proView.alpha = 1
            self.proView.isUserInteractionEnabled = true
            self.proView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.goToPro(_:))))
        } else {
            if hideWithAnimation {
                UIView.animate(withDuration: 0.25) {
                    proLabel.frame = CGRect(x: selfBtn.width - 40, y: 200, width: 25, height: 15)
                } completion: { (_) in
                    UIView.animate(withDuration: 0.2) {
                        self.proView.alpha = 0
                    }

                }

            } else {
                self.proView.alpha = 0
            }
        }
    }
    
    var wasOnPro = false
    @objc func goToPro(_ sender: UITapGestureRecognizer) {
        wasOnPro = true
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToPro", sender: self)
        }
        togglePurchaseButton(hideWithAnimation: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToPro":
            let vc = segue.destination as! BuyProVC
            vc.selectedProduct = 1
        default:
            print("default")
        }
    }
    
    
    @objc func refresh(sender:AnyObject) {
        print("refreshing")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if messageText != "" {
            DispatchQueue.main.async {
                self.newMessage.show(title:self.messageText, type: .standart)
//                self.message.showMessage(text: self.messageText, type: .error, windowHeight: 65, bottomAppearence: true)
                self.messageText = ""
            }
        }
        if didapp {
            self.getData()
        }
        
        
    }
    
    var foundInAListCount = 0
    func getData() {
        didapp = false
        categories = appData.getCategories(key: K.Keys.localCategories)
        transactions = appData.getLocalTransactions.sorted{ $0.dateFromString < $1.dateFromString }
        debts = appData.getDebts(key: K.Keys.localDebts)
        foundInAListCount = 0
        selectedCount = 0
        
        var holder:[UnsendedTransactions] = []
        defaultsTransactions = appData.getTransactions
        for transaction in transactions {
            foundInAListCount = contains(transaction) ? foundInAListCount + 1 : foundInAListCount
            let new = UnsendedTransactions(value: transaction.value, category: transaction.categoryID, date: transaction.date, comment: transaction.comment, selected: false)
            holder.append(new)
        }
        var catHolder: [UnsendedCategories] = []
        defaultsCategories = appData.getCategories()
        for category in categories {
            foundInAListCount = contains(category) ? foundInAListCount + 1 : foundInAListCount
            let new = UnsendedCategories(name: category.name, purpose: category.purpose, selected: false)
            catHolder.append(new)
            
        }
        
        var debtsHolder: [UnsendedDebts] = []
        defaultsDebts = appData.getDebts()
        for debt in debts {
            foundInAListCount = contains(debt) ? foundInAListCount + 1 : foundInAListCount
            let new = UnsendedDebts(name: debt.name, amountToPay: debt.amountToPay, dueDate: debt.dueDate, selected: false)
            debtsHolder.append(new)
        }
        
        categoruesTableData = catHolder
        tableDataTransactions = holder
        debtsTableData = debtsHolder
        DispatchQueue.main.async {
            if self.activity.isAnimating {
                self.activity.stopAnimating()
            }
            UIView.animate(withDuration: 0.4) {
                self.deleteSelectedButton.superview?.alpha = 1
                self.deleteAllButton.alpha = 1
            } completion: { (_) in
            }
        }
    }

    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    var sendPres = false
    @IBAction func sendPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        print(self.selectedCount, "self.selectedCountself.selectedCountself.selectedCountself.selectedCount")
        if !appData.proTrial && !appData.proVersion {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToPro", sender: self)
            }
        } else {
            if self.selectedCount == 0 {
                sendPres = true
                self.dismiss(animated: true) {
                    self.delegate?.quiteUnsendedData(deletePressed: false, sendPressed: true)
                }
            }
        }
        
    }
    var deletePress = false
    @IBAction func deletePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        deletePress = true
        if self.navigationController != nil {
            self.delegate?.quiteUnsendedData(deletePressed: true, sendPressed: false)
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true) {
                self.delegate?.quiteUnsendedData(deletePressed: true, sendPressed: false)
            }
        }
        
    }
    
    
    var defaultsTransactions:[TransactionsStruct] = []
    func contains(_ value: TransactionsStruct) -> Bool {
        var found: Bool?
        let dbData = Array(defaultsTransactions)
        
        for i in 0..<dbData.count {
            if value.comment == dbData[i].comment &&
                value.categoryID == dbData[i].categoryID &&
                value.date == dbData[i].date &&
                value.value == dbData[i].value {
                
                found = true
                return true
            }
        }
        if found == nil {
            return false
        } else {
            return found!
        }
    }
    
    var defaultsCategories: [CategoriesStruct] = []
    func contains(_ value: CategoriesStruct) -> Bool {
        var found: Bool?
        let dbData = Array(defaultsCategories)
        
        for i in 0..<dbData.count {
            if value.name == dbData[i].name &&
                value.purpose == dbData[i].purpose
            {
                found = true
                return true
            }
        }
        if found == nil {
            return false
        } else {
            return found!
        }
    }
    
    var defaultsDebts: [DebtsStruct] = []
    func contains(_ value: DebtsStruct) -> Bool {
        var found: Bool?
        let dbData = Array(defaultsDebts)
        
        for i in 0..<dbData.count {
            if value.name == dbData[i].name &&
                value.amountToPay == dbData[i].amountToPay && value.dueDate == dbData[i].dueDate
            {
                found = true
                return true
            }
        }
        if found == nil {
            return false
        } else {
            return found!
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !sendPres && !deletePress {
            self.delegate?.quiteUnsendedData(deletePressed: false, sendPressed: false)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    



    

    @IBAction func deleteSelectedPressed(_ sender: UIButton) {
        
        if selectedCount != 0 {
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            var result: [TransactionsStruct] = []
            result.removeAll()
            var newTable: [UnsendedTransactions] = []
            newTable.removeAll()
            foundInAListCount = 0
            selectedCount = 0
            defaultsTransactions = appData.getTransactions
            for trans in tableDataTransactions {
                if !trans.selected {
                    let new = TransactionsStruct(value: trans.value, categoryID: trans.category, date: trans.date, comment: trans.comment)
                    foundInAListCount = contains(new) ? foundInAListCount + 1 : foundInAListCount
                    result.append(new)
                    newTable.append(trans)
                }
            }
            appData.saveTransations(result, key: K.Keys.localTrancations)
            
            var newCategories: [UnsendedCategories] = []
            var defaultsCatsResult: [CategoriesStruct] = []
            newCategories.removeAll()
            defaultsCatsResult.removeAll()
            for cat in categoruesTableData {
                if !cat.selected {
                    let new = CategoriesStruct(name: cat.name, purpose: cat.purpose, count: 0)
                    foundInAListCount = contains(new) ? foundInAListCount + 1 : foundInAListCount
                    newCategories.append(cat)
                    defaultsCatsResult.append(new)
                    
                }
            }
            var newDebts: [UnsendedDebts] = []
            var defDebtsResult: [DebtsStruct] = []
            newDebts.removeAll()
            defDebtsResult.removeAll()
            for debt in debtsTableData {
                if !debt.selected {
                    let new = DebtsStruct(name: debt.name, amountToPay: debt.amountToPay, dueDate: debt.dueDate)
                    foundInAListCount = contains(new) ? foundInAListCount + 1 : foundInAListCount
                    newDebts.append(debt)
                    defDebtsResult.append(new)
                }
            }
            
            defaultsDebts = appData.getDebts()
            defaultsCategories = appData.getCategories()
            appData.saveCategories(defaultsCatsResult, key: K.Keys.localCategories)
            appData.saveDebts(defDebtsResult, key: K.Keys.localDebts)
            categoruesTableData = newCategories
            debtsTableData = newDebts
            tableDataTransactions = newTable
        }
    }

    

    @objc func selectRepeatedPressed(_ sender: UIButton){
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        defaultsTransactions = appData.getTransactions
        selectedCount = 0
        foundInAListCount = 0
        var all = Array(self.tableDataTransactions)
        for i in 0..<all.count {
            if all[i].selected {
                self.selectedCount += 1
            } else {
                if contains(TransactionsStruct(value: all[i].value, categoryID: all[i].category, date: all[i].date, comment: all[i].comment)) {
                    self.selectedCount += 1
                    all[i].selected = true
                }
            }
            
        }
        
        var allCats = Array(self.categoruesTableData)
        for i in 0..<allCats.count {
            if allCats[i].selected {
                self.selectedCount += 1
            } else {
                if contains(CategoriesStruct(name: allCats[i].name, purpose: allCats[i].purpose, count: 0)) {
                    self.selectedCount += 1
                    allCats[i].selected = true
                }
            }
        }
        
        var allDebts = Array(self.debtsTableData)
        for i in 0..<allDebts.count {
            if allDebts[i].selected {
                self.selectedCount += 1
            } else {
                if contains(DebtsStruct(name: allDebts[i].name, amountToPay: allDebts[i].amountToPay, dueDate: allDebts[i].dueDate)) {
                    self.selectedCount += 1
                    allDebts[i].selected = true
                }
            }
        }
        
        debtsTableData = allDebts
        categoruesTableData = allCats
        tableDataTransactions = all
        
    }
    
    
    @objc func selectAllInSectionPressed(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            UIImpactFeedbackGenerator().impactOccurred()
        }
        
        if let name = sender.name {
            if let section = Int(name) {
             //   var holder = tableDataTransactions
                selectedCount = 0
                var holder = tableDataTransactions
                for i in 0..<tableDataTransactions.count {
                    if tableDataTransactions[i].selected {
                        selectedCount += 1
                    }
                }
                for i in 0..<categoruesTableData.count {
                    if categoruesTableData[i].selected {
                        selectedCount += 1
                    }
                }
                for i in 0..<debtsTableData.count {
                    if debtsTableData[i].selected {
                        selectedCount += 1
                    }
                }
                
                switch section {
                case 2:
                    for i in 0..<holder.count {
                        if !holder[i].selected {
                            selectedCount += 1
                            holder[i].selected = true
                        }
                    }
                    self.tableDataTransactions = holder
                case 3:
                    var catHolder = categoruesTableData
                    for i in 0..<catHolder.count {
                        if !catHolder[i].selected {
                            selectedCount += 1
                            catHolder[i].selected = true
                        }
                    }
                    
                    self.categoruesTableData = catHolder
                    self.tableDataTransactions = holder
                case 4:
                    var debtsHolder = debtsTableData
                    for i in 0..<debtsHolder.count {
                        if !debtsHolder[i].selected {
                            selectedCount += 1
                            debtsHolder[i].selected = true
                        }
                    }
                    self.debtsTableData = debtsHolder
                    self.tableDataTransactions = holder
                default:
                    print("defaultSelected")
                }
                

                
            }
        }
    }
    var selectedCount = 0
    
    let lightTrash = UIImage(named: "lightTrash") ?? UIImage()
    let redTrash = UIImage(named: "redTrash") ?? UIImage()
    let redPlusImage = UIImage(named: "ovalPlus") ?? UIImage()
    
    var debtsCellLabelsFrame: (CGRect, CGRect) = (.zero, .zero)
    
    //var firstSectionHeight: CGFloat = 0
    //firstSectionHeight
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       // let finger = scrollView.panGestureRecognizer.location(in: self.view)
      /*  if scrollView.contentOffset.y < -10 {
            
            if firstSectionHeight == 0 {
                firstSectionHeight = self.view.frame.height - 200
                DispatchQueue.main.async {
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
                    }
                }
            }
            
        }*/
    }
}


extension UnsendedDataVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return foundInAListCount > 0 ? 1 : 0
        case 2: return tableDataTransactions.count
        case 3: return categoruesTableData.count
        case 4: return debtsTableData.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2: return "Transactions"
        case 3: return "Categories"
        case 4: return "Debts"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath == IndexPath(row: 0, section: 0) ? 0 : UITableView.automaticDimension //self.view.frame.height - 200
    }
    
    /*func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       /* if indexPath == IndexPath(row: 0, section: 0) {
            firstSectionHeight = 0
        }*/
    }*/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell") as! descriptionCell
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "repeatedDataCell") as! repeatedDataCell
            
            cell.selectButton.setTitle("Select (\(self.foundInAListCount))", for: .normal)
            cell.selectButton.addTarget(self, action: #selector(self.selectRepeatedPressed(_:)), for: .touchUpInside)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unsendedTransactionsCell", for: indexPath) as! unsendedTransactionsCell
            let data = tableDataTransactions[indexPath.row]
            cell.categoryLabel.text = data.category
            cell.commentLabel.text = data.comment
            cell.dateLabel.text = data.date
            cell.valueLabel.text = String(format:"%.0f", Double(data.value) ?? 0.0)
            cell.treshImage.image = data.selected ? redTrash : lightTrash
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unsendedCategoriesCell") as! unsendedCategoriesCell
            let data = categoruesTableData[indexPath.row]
            cell.nameLabel.text = data.name
            cell.perposeLabel.text = data.purpose
            cell.trashImage.image = data.selected ? redTrash : lightTrash
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "unsendedDebtsCell") as! unsendedDebtsCell
            let data = debtsTableData[indexPath.row]
            cell.nameLabel.text = data.name
            cell.dueDateLabel.text = data.dueDate == "" ? "-" : data.dueDate
            cell.amountLabel.text = data.amountToPay == "" ? "-" : data.amountToPay
            cell.treshImage.image = data.selected ? redTrash : lightTrash
            if debtsCellLabelsFrame == (.zero, .zero) {
                self.debtsCellLabelsFrame = ((cell.dueDateLabel.superview?.frame ?? .zero), (cell.dueDateLabel.frame))
            }
            
            print(debtsCellLabelsFrame, "debtsCellLabelsFramedebtsCellLabelsFramedebtsCellLabelsFrame")
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        case 1: return 0
        case 2: return tableDataTransactions.count == 0 ? 0 : 25
        case 3: return categoruesTableData.count == 0 ? 0 : 25
        case 4: return debtsTableData.count == 0 ? 0 : 25
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 || section != 1 {
            let mainFrame = self.view.frame
            let height:CGFloat = 25
            let view = UIView(frame: CGRect(x: 0, y: 0, width: mainFrame.width, height: height))
            let labels = UILabel()
            let heplerView = UIView(frame: CGRect(x: (mainTitleLabel.superview?.superview?.frame.minX ?? 0.0), y: 4, width: (mainFrame.width - 20) / 2, height: height))
            view.addSubview(heplerView)
            let stackview = UIStackView()
            stackview.spacing = 5
            stackview.alignment = .fill
            stackview.distribution = .equalSpacing
            stackview.axis = .horizontal
            heplerView.addSubview(stackview)
            var title = ""
            switch section {
            case 2:
                title = "Transactions"
            case 3:
                title = "Categories"
            case 4:
                title = "Debts"
               // let secondheplerView = UIView(frame: CGRect(x: tableView.frame.width / 2 - 42, y: 0, width: tableView.frame.width / 2 - 42, height: height))
                //secondheplerView.backgroundColor = .green
               // view.addSubview(secondheplerView)
                let secondStack = UIStackView(frame: CGRect(x: tableView.frame.width / 2 - 22, y: 0, width: tableView.frame.width / 2 - 37, height: height))
                //secondStack.translatesAutoresizingMaskIntoConstraints = false
                secondStack.alignment = .fill
                secondStack.distribution = .fillEqually
                secondStack.axis = .horizontal
               // let amountX = debtsCellLabelsFrame.0.minX + 20
                let amountLabel = UILabel()//UILabel(frame: CGRect(x: amountX, y: 0, width: 100, height: 25))
                amountLabel.text = "Amount"
                amountLabel.textColor = UIColor(named: "CategoryColor") ?? .red
                amountLabel.font = .systemFont(ofSize: 14, weight: .medium)
                amountLabel.translatesAutoresizingMaskIntoConstraints = false
                secondStack.addArrangedSubview(amountLabel)
              //  view.addSubview(amountLabel)
                //let dueDateLabel = UILabel(frame: debtsCellLabelsFrame.1)
                let dueDateLabel = UILabel()//UILabel(frame: CGRect(x: amountX + debtsCellLabelsFrame.1.minX + 7, y: 0, width: 100, height: 25))
                dueDateLabel.text = "Due Date"
                dueDateLabel.textColor = UIColor(named: "CategoryColor") ?? .red
                dueDateLabel.font = .systemFont(ofSize: 14, weight: .medium)
                dueDateLabel.translatesAutoresizingMaskIntoConstraints = false
                secondStack.addArrangedSubview(dueDateLabel)
                view.addSubview(secondStack)
            //    secondheplerView.addSubview(secondStack)
            default:
                title = ""
            }
            labels.text = title
            view.backgroundColor = UIColor(named: "darkTableColor")
            labels.font = .systemFont(ofSize: 14, weight: .medium)
            labels.textColor = UIColor(named: "CategoryColor") ?? .red
            let plusIcon = UIImageView()
            plusIcon.image = redPlusImage
            let gestur = UITapGestureRecognizer(target: self, action: #selector(selectAllInSectionPressed(_:)))
            gestur.name = "\(section)"
            heplerView.isUserInteractionEnabled = true
            heplerView.addGestureRecognizer(gestur)
            labels.translatesAutoresizingMaskIntoConstraints = false
            plusIcon.translatesAutoresizingMaskIntoConstraints = false
            stackview.addArrangedSubview(labels)
            stackview.addArrangedSubview(plusIcon)
            labels.adjustsFontSizeToFitWidth = true
            stackview.translatesAutoresizingMaskIntoConstraints = false
            
            //if 3 add stack view
            
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 || indexPath.section != 1 {

            switch indexPath.section {
            case 2:
                tableDataTransactions[indexPath.row].selected = tableDataTransactions[indexPath.row].selected ? false : true
            case 3:
                categoruesTableData[indexPath.row].selected = categoruesTableData[indexPath.row].selected ? false : true
            case 4:
                debtsTableData[indexPath.row].selected = debtsTableData[indexPath.row].selected ? false : true
            default:
                print("default")
            }
            let trans = tableDataTransactions
            selectedCount = 0
            for cat in categoruesTableData {
                if cat.selected {
                    selectedCount += 1
                }
            }
            for trans in tableDataTransactions {
                if trans.selected {
                    selectedCount += 1
                }
            }
            for debt in debtsTableData {
                if debt.selected {
                    selectedCount += 1
                }
            }
            tableDataTransactions = trans
            DispatchQueue.main.async {
               // self.tableView.reloadData()
                self.deleteSelectedButton.setTitle("Delete (\(self.selectedCount))", for: .normal)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section != 0 || indexPath.section != 1 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                switch indexPath.section {
                case 2:
                    self.transactions.remove(at: indexPath.row)
                    appData.saveTransations(self.transactions, key: K.Keys.localTrancations)
                    self.getData()
                case 3:
                    self.categories.remove(at: indexPath.row)
                    appData.saveCategories(self.categories, key: K.Keys.localCategories)
                    self.getData()
                case 4:
                    self.debts.remove(at: indexPath.row)
                    appData.saveDebts(self.debts, key: K.Keys.localDebts)
                    self.getData()
                default:
                    print("default")
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            return UISwipeActionsConfiguration(actions: selectedCount == 0 ? [deleteAction] : [])
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if wasOnPro {
            //fatalError()
            wasOnPro = false
            togglePurchaseButton(hideWithAnimation: true)
        }
    }

}

class unsendedTransactionsCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var treshImage: UIImageView!
}
class unsendedCategoriesCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var perposeLabel: UILabel!
    @IBOutlet weak var trashImage: UIImageView!
    
}

class repeatedDataCell: UITableViewCell {
    @IBOutlet weak var selectButton: UIButton!
    
}

class unsendedDebtsCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var treshImage: UIImageView!
}

class descriptionCell: UITableViewCell {
    
}
