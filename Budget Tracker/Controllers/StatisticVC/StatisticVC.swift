//
//  statisticVC.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 17.03.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit
import CorePlot

var filterAndGoToStatistic: IndexPath?
class StatisticVC: SuperViewController, CALayerDelegate {
    @IBOutlet weak var hostView: CPTGraphHostingView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    var allData = [GraphDataStruct]()

    
    var dataFromMain: [TransactionsStruct] = []
    var sum = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()

    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        deselectAllCells()
        if transactionAdded {
            appData.needDownloadOnMainAppeare = true
            updateUI()
            
        }
       // segmentControll.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white], for: .normal)
       // segmentControll.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "darkTableColor") ?? .black], for: .selected)
        
        DispatchQueue(label: "local", qos: .userInitiated).async {
            if self.db.viewControllers.firstLaunch[.statistic] ?? false == false {
                self.db.viewControllers.firstLaunch[.statistic] = true
            }
        }

    }
    
    func deselectAllCells() {
        for i in 0..<allData.count {
            let indexPath = IndexPath(row: i, section: 0)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func hideandShowGrapg() {
        hostView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.hostView.alpha = 1
        }
    }
    
    func getMaxSum() {
        let all = allData
        for i in 0..<all.count {
            sum += all[i].value
        }
    }
    
    func getPercent(n: Double) -> Double {
        if allData.count != 0 {
            let biggest = sum
            let results = ((100 * n) / biggest)
            return results
        } else { return 0.0 }
    }
    
    func updateUI() {
        sum = 0.0
        tableView.delegate = self
        tableView.dataSource = self
        if appData.expenseLabelPressed == true {
            segmentControll.selectedSegmentIndex = 0
        } else {
            segmentControll.selectedSegmentIndex = 1
        }
        let d = createTableData()
        allData = d
        getMaxSum()
        initPlot()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    var fromsideBar = false
    var selectedSegment = 0
    var maxValue = 0.0
    var isAll:Bool = false
    func createTableData() -> [GraphDataStruct] {
        maxValue = 0.0
        allData.removeAll()
        let data = Array(dataFromMain)
     //   if segmentControll.selectedSegmentIndex == 0 {
            var resultDict: [String:[TransactionsStruct]] = [:]
            for i in 0..<data.count {
                var newTransactions = resultDict["\(data[i].categoryID)"] ?? []
                newTransactions.append(data[i])
                let intValue = Double(data[i].value) ?? 0
                if appData.expenseLabelPressed {
                    if intValue < 0 {
                        maxValue = intValue < maxValue ? intValue : maxValue
                    }
                    
                } else {
                    if intValue > 0 {
                        maxValue = intValue > maxValue ? intValue : maxValue
                    }
                    
                }
                
                resultDict.updateValue(newTransactions, forKey: "\(data[i].categoryID)")
            }
        var totalAmount = 0.0
            for (key, value) in resultDict {
                let transactions = resultDict[key] ?? []
                
                let category = db.category(key) ?? (NewCategories(id: -1, name: "Unknown".localize, icon: "", color: "", purpose: .debt))
                var value = 0.0
                for n in 0..<transactions.count {
                    value += (Double(transactions[n].value) ?? 0.0)
                }
                
                if appData.expenseLabelPressed {
                    
                 //   if category.purpose != .income {
                        if value < 0 {
                            allData.append(GraphDataStruct(category: category, transactions: transactions, value: value))
                            totalAmount += value
                        }
                        
                  //  }
                } else {
                    
              //      if category.purpose != .expense {
                        if value > 0 {
                            totalAmount += value
                            allData.append(GraphDataStruct(category: category, transactions: transactions, value: value))
                        }
                        
                 //   }
                }
                
            }
            

        
        let textt = (isAll ? "All period" : appData.filter.periodText).localize
            DispatchQueue.main.async {
                self.titleLabel.text = (appData.expenseLabelPressed ? "Expenses".localize : "Incomes".localize) + " " + "for".localize + " " + textt
                self.totalLabel.text = "\(Int(totalAmount))"
            }
            ifNoData()
        return allData.sorted(by: { appData.expenseLabelPressed ? $1.value > $0.value : $1.value < $0.value})

        
    }
    
    func ifNoData() {
        if allData.count == 0 {
            DispatchQueue.main.async {
                self.titleLabel.textAlignment = .center
                self.titleLabel.text = "No".localize + " " + (self.titleLabel.text ?? "Data".localize)
                self.titleLabel.alpha = 0.1
            }
        } else {
            DispatchQueue.main.async {
                self.titleLabel.alpha = 1
                self.titleLabel.textAlignment = .left
            }
        }
    }
    
    @IBAction func selectedSegment(_ sender: UISegmentedControl) {
        appData.expenseLabelPressed = sender.selectedSegmentIndex == 1 ? false : true
        allData = createTableData()
        sum = 0.0
        getMaxSum()
        initPlot()
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
        hideandShowGrapg()
    }
    
    @IBAction func clodePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
      //  navigationController?.navigationBar.backgr
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
  /*  override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }*/
    
    var fromDebts: Bool = false
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategoryName = ""
    var selectedIndexPathToHighlite: IndexPath?
    func toHistoryVC(indexPathRow: Int) {
        selectedIndexPathToHighlite = IndexPath(row: indexPathRow, section: 0)
        historyDataStruct = allData[indexPathRow].transactions
        selectedCategoryName = "\(allData[indexPathRow].category.id)"

        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toHistorySeque", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHistorySeque" {
            let vc = segue.destination as! HistoryVC
            vc.fromStatistic = true
            vc.historyDataStruct = historyDataStruct
            let db = DataBase()
            vc.selectedCategory = db.category(selectedCategoryName)
            vc.selectedPurposeH = segmentControll.selectedSegmentIndex
            vc.fromCategories = fromDebts
            vc.allowEditing = false
        }
    }
    
    @IBOutlet weak var totalLabel: UILabel!
    
    func initPlot() {
        hostView.allowPinchScaling = false
        configureGraph()
        configureChart()
    }

    func configureGraph() {
        let graph = CPTXYGraph(frame: hostView.bounds)
        hostView.hostedGraph = graph
        graph.paddingLeft = 0.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0
        graph.paddingBottom = 0.0
        graph.axisSet = nil

    }
    
    func configureChart() {
        // 1 - Get a reference to the graph
        let graph = hostView.hostedGraph!
        
        // 2 - Create the chart
        let pieChart = CPTPieChart()
        pieChart.delegate = self
        pieChart.dataSource = self
        pieChart.pieRadius = (min(hostView.bounds.size.width, hostView.bounds.size.height) * 0.7) / 2
        pieChart.sliceDirection = .clockwise
        pieChart.labelOffset = -0.7 * pieChart.pieRadius
        
        // 3 - Configure border style
        let borderStyle = CPTMutableLineStyle()
        borderStyle.lineColor = CPTColor(uiColor: K.Colors.background ?? UIColor.white)
        borderStyle.lineWidth = 0.5
        pieChart.borderLineStyle = borderStyle
        
        // 4 - Configure text style
        let textStyle = CPTMutableTextStyle()
        textStyle.textAlignment = .left
        textStyle.fontSize = 10
        textStyle.color = CPTColor(uiColor: .white)//K.Colors.category ?? UIColor.white)
        pieChart.labelTextStyle = textStyle
        // 5 - Add chart to graph
        graph.add(pieChart)
    }
    

    
    
    var selectedIndexPath = 0
    @objc func deselectRow() {
        let indexPax = IndexPath(row: selectedIndexPath, section: 0)
        tableView.deselectRow(at: indexPax, animated: true)
    }
    
}


// table view
extension StatisticVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.statisticCellIdent, for: indexPath) as! StatisticCell
        let data = allData[indexPath.row]
        cell.amountLabel.textColor = data.value > 0.0 ? K.Colors.category : K.Colors.negative

        if data.value < Double(Int.max) {
            cell.amountLabel.text = "\(Int(data.value))"
        } else {
            cell.amountLabel.text = "\(data.value)"
        }
        cell.categoryLabel.text = "\(data.category.name.capitalized)"
        cell.percentLabel.text = "\(String(format: "%.2f", getPercent(n: data.value)))%"
        let r = (100 * data.value / maxValue) / 100
        cell.progressBar.progress = Float(r)

        cell.progressBar.tintColor = AppData.colorNamed(allData[indexPath.row].category.color)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.init(label: "sort", qos: .userInteractive).async {
            self.toHistoryVC(indexPathRow: indexPath.row)
        }
    }
    
    //let goIndex = filterAndGoToStatistic


    
   /* func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let goIndex = filterAndGoToStatistic {
            if indexPath == goIndex {
                
                DispatchQueue.main.async {
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                    Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
                        tableView.deselectRow(at: indexPath, animated: true)
                        filterAndGoToStatistic = nil
                    }
                }
            }
        }
    }*/
}


//MARK: - core plot
extension StatisticVC: CPTPieChartDataSource, CPTPieChartDelegate {
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(allData.count)
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        let cell = allData[Int(idx)].value
        return cell
    }
    
    func sliceFill(for pieChart: CPTPieChart, record idx: UInt) -> CPTFill? {
        let color = AppData.colorNamed(allData[Int(idx)].category.color)
        return CPTFill(color: CPTColor(uiColor: color))
       
    }
    
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        
        let value = getPercent(n: allData[Int(idx)].value)
        //let title = allData[Int(idx)].category
        if value > 10.0 {
            //let layer = CPTTextLayer(text: "\(title.capitalized)\n\(Int(value))%")
            let layer = CPTTextLayer(text: "\(Int(value))%")
            layer.textStyle = plot.labelTextStyle
            return layer
        } else {
            let layer = CPTTextLayer(text: "")
            return layer
        }
    }
    
    func pieChart(_ plot: CPTPieChart, sliceWasSelectedAtRecord idx: UInt) {
        
        selectedIndexPath = Int(idx)
        let indexPath = IndexPath(row: Int(idx), section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        
        Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(deselectRow), userInfo: nil, repeats: false)
    }
}

struct GraphDataStruct {
    var category: NewCategories
    var transactions: [TransactionsStruct]
    var value: Double
}

