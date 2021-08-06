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
class StatisticVC: SuperViewController, CALayerDelegate, UNUserNotificationCenterDelegate {
    @IBOutlet weak var hostView: CPTGraphHostingView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    var allData = [GraphDataStruct]()

    
    var dataFromMain: [TransactionsStruct] = []
    var sum = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        center.delegate = self
        updateUI()

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       notificationReceiver(notification: notification)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        deselectAllCells()
        if transactionAdded {
            filterAndGoToStatistic = selectedIndexPathToHighlite
            //self.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "homeVC", sender: self)
            }
        }
        segmentControll.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: K.Colors.balanceV ?? .white], for: .normal)
        segmentControll.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "darkTableColor") ?? .black], for: .selected)
        
        if appData.defaults.value(forKey: "StatisticVCFirstLaunch") as? Bool ?? false == false {
            appData.defaults.setValue(true, forKey: "StatisticVCFirstLaunch")
            DispatchQueue.main.async {
                self.message.showMessage(text: "Statistic for your transactions will be displayed here", type: .succsess, windowHeight: 80)
            }
        }
        
        if let goIndex = filterAndGoToStatistic { // search by name
            filterAndGoToStatistic = nil
            if allData.count > goIndex.row {
               /* DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: goIndex, at: .middle, animated: true)
                }*/
            } else {
                //filterAndGoToStatistic = nil
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
        for i in 0..<allData.count {
            sum += allData[i].value
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
        if expenseLabelPressed == true {
            segmentControll.selectedSegmentIndex = 0
        } else { segmentControll.selectedSegmentIndex = 1 }
        allData = createTableData()
        getMaxSum()
        initPlot()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    var maxValue = 0.0
    func createTableData() -> [GraphDataStruct] {
        maxValue = 0.0
        allData = []
        if segmentControll.selectedSegmentIndex == 0 {
            for (key, value) in sumAllCategories {
                if (sumAllCategories[key] ?? 0.0) < 0.0 {
                    maxValue = value < maxValue ? value : maxValue
                    allData.append(GraphDataStruct(category: key, value: value))
                }
            }
            DispatchQueue.main.async {
                self.titleLabel.text = "Expenses for \(selectedPeroud)"
            }
            ifNoData()
            return allData.sorted(by: { $1.value > $0.value})
        } else {
            for (key, value) in sumAllCategories {
                if (sumAllCategories[key] ?? 0.0) > 0.0 {
                    maxValue = value > maxValue ? value : maxValue
                    allData.append(GraphDataStruct(category: key, value: value))
                }
            }
            DispatchQueue.main.async {
                self.titleLabel.text = "Incomes for \(selectedPeroud)"
            }
            ifNoData()
            return allData.sorted(by: { $0.value > $1.value})
        }
        
    }
    
    func ifNoData() {
        if allData.count == 0 {
            DispatchQueue.main.async {
                self.titleLabel.textAlignment = .center
                self.titleLabel.text = "No " + (self.titleLabel.text ?? "Data")
            }
        } else {
            DispatchQueue.main.async {
                self.titleLabel.textAlignment = .left
            }
        }
    }
    
    @IBAction func selectedSegment(_ sender: UISegmentedControl) {
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
    
    var fromDebts: Bool = false
    var historyDataStruct: [TransactionsStruct] = []
    var selectedCategoryName = ""
    var selectedIndexPathToHighlite: IndexPath?
    func toHistoryVC(indexPathRow: Int) {
        selectedIndexPathToHighlite = IndexPath(row: indexPathRow, section: 0)
        historyDataStruct = []
        for i in 0..<dataFromMain.count {
            if allData[indexPathRow].category == dataFromMain[i].category {
                historyDataStruct.append(dataFromMain[i])
            }
        }
        fromDebts = false
        
        let allDebts = Array(appData.getDebts())
        for i in 0..<allDebts.count {
            if allData[indexPathRow].category == allDebts[i].name {
                fromDebts = true
                break
            }
        }

        print(historyDataStruct.count, "historyDataStructhistoryDataStructhistoryDataStructhistoryDataStruct")
        selectedCategoryName = allData[indexPathRow].category
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toHistorySeque", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHistorySeque" {
            let vc = segue.destination as! HistoryVC
            vc.fromStatistic = true
            vc.historyDataStruct = historyDataStruct
            vc.selectedCategoryName = selectedCategoryName
            vc.selectedPurposeH = segmentControll.selectedSegmentIndex
            vc.fromCategories = fromDebts
        }
    }
    
    
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
        borderStyle.lineWidth = 1.5
        pieChart.borderLineStyle = borderStyle
        
        // 4 - Configure text style
        let textStyle = CPTMutableTextStyle()
        textStyle.textAlignment = .left
        textStyle.fontSize = 15
        textStyle.color = CPTColor(uiColor: K.Colors.category ?? UIColor.white)
        pieChart.labelTextStyle = textStyle
        
        // 5 - Add chart to graph
        graph.add(pieChart)
    }
    
    func colorComponentsFrom(number:Int,maxCount:Int) -> (Int,Int,Int){
        let maxColor = Double(0xFFFFFF - 0x222222);
        let ratio = maxColor / Double(maxCount);
        let intColor = lround(ratio * Double(number)) ;
        let redComponent =      ((intColor & 0xFFAFAF) >> (2*8)) & 0x22;
        let greenComponent =    ((intColor & 0xAFFFAF) >> (1*8)) & 0x22;
        let blueComponent =     ((intColor & 0x9B9BFF) >> (0*8)) & 0xff;
        return (redComponent,greenComponent,blueComponent);
    }
    
    func setupColorView(indexPath: Int) -> UIColor {
        var n = indexPath
        if indexPath == 0 { n = 100 }
        let colorComponents = colorComponentsFrom(number: Int(String(n)) ?? 0, maxCount: Int(allData[0].value))
        let result = UIColor(displayP3Red: CGFloat(colorComponents.0)/255, green: CGFloat(colorComponents.1)/255, blue: CGFloat(colorComponents.2)/255, alpha: 0.7)
        return result
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
        
        if data.value > 0.0 {
            cell.amountLabel.textColor = UIColor(named: "darkTableColor")
        } else { cell.amountLabel.textColor = K.Colors.negative }
        if data.value < Double(Int.max) {
            cell.amountLabel.text = "\(Int(data.value))"
        } else {
            cell.amountLabel.text = "\(data.value)"
        }
        cell.categoryLabel.text = "\(data.category.capitalized)"
        cell.percentLabel.text = "\(String(format: "%.2f", getPercent(n: data.value)))%"
        let r = (100 * data.value / maxValue) / 100
        cell.progressBar.progress = Float(r)
        let color = setupColorView(indexPath: indexPath.row)
       // cell.colorView.layer.cornerRadius = 3
       // cell.colorView.backgroundColor = color
        cell.progressBar.tintColor = color
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
        
        var n = idx
        if idx == 0 { n = 100 }
        let colorComponents = colorComponentsFrom(number: Int(String(n)) ?? 0, maxCount: Int(allData[0].value))
        return CPTFill(color: CPTColor(componentRed: CGFloat(colorComponents.0)/255, green: CGFloat(colorComponents.1)/255, blue: CGFloat(colorComponents.2)/255, alpha: 0.7))
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
    var category: String
    var value: Double
}

