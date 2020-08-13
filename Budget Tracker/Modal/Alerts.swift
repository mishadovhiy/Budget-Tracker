//
//  Alerts.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 10.02.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

class Alerts {
   
    func alertTextField(alert: UIAlertController) {
        alert.addTextField { (dateFrom) in
            appData.filter.filterObjects.startDatePicker.datePickerMode = .date
            dateFrom.inputView = appData.filter.filterObjects.startDatePicker
            dateFrom.placeholder = "From"
            appData.filter.filterObjects.startDateField = dateFrom
            appData.filter.filterObjects.startDatePicker.addTarget(self, action: #selector(self.startDatePickerChangedValue(sender:)), for: .valueChanged)
        }
            
        alert.addTextField { (dateTo) in
            appData.filter.filterObjects.endDatePicker.datePickerMode = .date
            dateTo.inputView = appData.filter.filterObjects.endDatePicker
            dateTo.placeholder = "To"
            appData.filter.filterObjects.endDateField = dateTo
            appData.filter.filterObjects.endDatePicker.addTarget(self, action: #selector(self.endDatePickerChangedValue(sender:)), for: .valueChanged)
        }
    }

    
//MARK: - selectors
    @objc func startDatePickerChangedValue(sender: UIDatePicker) {
        appData.filter.filterObjects.startDateField.text = appData.stringDate(sender)
    }
            
    @objc func endDatePickerChangedValue(sender: UIDatePicker) {
        appData.filter.filterObjects.endDateField.text = appData.stringDate(sender)
    }
    
}


class MessageView {
    
    let mainView: UIViewController
    let subview = UIView()
    let textLabel = UILabel()
    let closeButton = UIButton()
    
    enum MessageType {
        case error
        case succsess
        case staticError
    }
    @objc func closeButtonPressed(_ sender: Any) {
        hideMessage()
    }

    func hideMessage(duration: TimeInterval = 0.2) {
        stopTimers()
        
        closeButton.alpha = 0
        UIView.animate(withDuration: duration) {
            self.subview.frame = CGRect(x: 0, y: -80, width: 10, height: 30)
            self.textLabel.alpha = 0
        }
    }
    
    
    var timers = [Timer]()
    func stopTimers() {
        for i in 0..<timers.count {
            timers[i].invalidate()
        }
    }
    
    func showMessage(text: String, type: MessageType, windowHeight: CGFloat = 30) {

        hideMessage(duration: 0)
        DispatchQueue.main.async {
            self.textLabel.text = text
        }
        self.subview.frame = CGRect(x: 40, y: -80, width: self.mainView.view.bounds.width - 40, height: windowHeight)
        UIView.animate(withDuration: 0.4) {
            self.subview.frame = CGRect(x: 20, y: self.mainView.view.safeAreaInsets.top + 5, width: self.mainView.view.bounds.width - 40, height: windowHeight)
            self.textLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.8) {
            self.closeButton.alpha = 1
        }
        self.textLabel.frame = CGRect(x: 5, y: 5, width: self.subview.frame.width - 5, height: windowHeight - 10)
        self.closeButton.frame = CGRect(x: self.subview.frame.width - 30, y: 0, width: 30, height: windowHeight)
        
        
        switch type {
        case .error:
            UIView.animate(withDuration: 0.4) {
                self.textLabel.textColor = K.Colors.balanceV
                self.subview.backgroundColor = UIColor.red
            }
            let timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false) { (action) in
                self.hideMessage()
            }
            timers.append(timer)
        case .succsess:
            UIView.animate(withDuration: 0.4) {
                self.textLabel.textColor = K.Colors.balanceV
                self.subview.backgroundColor = K.Colors.yellow
            }
            let timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false) { (action) in
                self.hideMessage()
            }
            timers.append(timer)
        case .staticError:
            UIView.animate(withDuration: 0.4) {
                self.textLabel.textColor = K.Colors.balanceV
                self.subview.backgroundColor = UIColor.red
            }
        }
        
    }
    
    func initMessage() {

        closeButton.alpha = 0
        textLabel.alpha = 0
        mainView.view.addSubview(subview)
        subview.addSubview(closeButton)
        subview.addSubview(textLabel)
        closeButton.addTarget(self, action: #selector(closeButtonPressed(_:)), for: .allEvents)
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textLabel.textAlignment = .left
        closeButton.setImage(UIImage(named: "cancel"), for: .normal)
        subview.layer.cornerRadius = 4
        subview.layer.shadowColor = UIColor.black.cgColor
        subview.layer.shadowOpacity = 0.3
        subview.layer.shadowOffset = .zero
        subview.layer.shadowRadius = 4
        print("message init")
    }
    
    func constraintAdd() {
        //subview
      //  let saveArTopHeight: CGFloat = 10
        //let verticalSubview = NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let topSubview = NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 5)
        let widthSubview = NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 280)
        let heightSubview = NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 100)
        let leftSubview = NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: UIApplication.shared.keyWindow, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
        
        let topLabel = NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let bottomLabel = NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let leftLabel = NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
        let rightLabel = NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 35)
        
        let bottomBtn = NSLayoutConstraint(item: closeButton, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let widthBtn = NSLayoutConstraint(item: closeButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 30)
        let topBtn = NSLayoutConstraint(item: closeButton, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let rightBtn = NSLayoutConstraint(item: closeButton, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: subview, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
        subview.translatesAutoresizingMaskIntoConstraints = false
        mainView.view.addSubview(subview)
        mainView.view.addConstraints([topSubview, widthSubview, heightSubview, leftSubview])
        subview.addSubview(closeButton)
        mainView.view.addConstraints([bottomBtn, widthBtn, topBtn, rightBtn])
        subview.addSubview(textLabel)
        mainView.view.addConstraints([topLabel, bottomLabel, leftLabel, rightLabel])
        
    }
    
    
    init(_ mainView: UIViewController) {
        self.mainView = mainView
        initMessage()
    }
    
}
