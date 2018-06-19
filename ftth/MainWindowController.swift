//
//  MainWindowController.swift
//  ftth
//
//  Created by Schappet, James C on 6/11/18.
//  Copyright © 2018 Schappet.com. All rights reserved.
//

import Foundation

import UIKit
import SwiftDate

struct CurrentStatus {
    var heartRateReady = false
    var weightReady = false
    var stepReady = false
    
    func isReady() -> Bool {
        return heartRateReady && weightReady && stepReady
    }
}

class MainViewController: UIViewController {

    // HealthKit setup
    let healthKitInterface = HealthKitInterface()
    var yesterdaysVitals = [HealthItem]()
    
    var textField = UITextField()
    var datePicker = UIDatePicker()
    var toolBar = UIToolbar()
    

    
    
    let cal = Calendar(identifier: .gregorian)

    let client = MyDbClient()
    
    var currentStatus = CurrentStatus() {
        didSet {
            DispatchQueue.main.async {

                self.uploadData.isEnabled = self.currentStatus.isReady()
                self.uploadData.isHidden = !self.currentStatus.isReady()
            }
            print("Is Ready: \(currentStatus.isReady())")
        }
    }
    
    
    @IBOutlet weak var weightCount: UITextField!
    
    @IBOutlet weak var heartRateCount: UITextField!
    
    @IBOutlet weak var stepCount: UITextField!
    
    @IBOutlet weak var uploadData: UIButton!
    
    
    @IBAction func performUploadOfData(_ sender: Any) {
        let beginDate = cal.startOfDay(for: datePicker.date)

        client.postYesterdaysHealthData(date: beginDate, items: yesterdaysVitals)
        print("button clicked")
        
    }
    
    @IBAction func getHealthData(_ sender: Any) {
        
        getYesterdayData()
        
    }
    
    
    func getYesterdayData() {
        
        //let oneWeekAgo: Date = 2.days.ago()!
        
        //let oneDayAgo: Date = 1.days.ago()!
        
        let beginDate = cal.startOfDay(for: datePicker.date)
        let endDate = beginDate.addingTimeInterval(86400)
        print(beginDate)
        print(endDate)
        
        healthKitInterface.readHealthData(startDate: beginDate, endDate: endDate,
                                          identifier: .heartRate, completion: { (hkItems, error) in
                                          DispatchQueue.main.async {
                                                
                                            self.yesterdaysVitals += hkItems!
                                            self.currentStatus.heartRateReady = true
                                            //self.uploadData.isEnabled = self.currentStatus.isReady()
                                                self.heartRateCount.text = "\(String(describing: hkItems!.count))"
                                            }
                                            print("Heart Rate Count: \(hkItems!.count)")}
                                        
        )
        
        healthKitInterface.readHealthData(startDate: beginDate, endDate: endDate,
                                          identifier: .bodyMass, completion: { (hkItems, error) in
                                          DispatchQueue.main.async {
                                            self.yesterdaysVitals += hkItems!
                                            self.currentStatus.weightReady = true
                                            //self.uploadData.isEnabled = self.currentStatus.isReady()
                                          
                                                self.weightCount.text = "\(String(describing: hkItems!.count))"
                                            }
                                            print("Weight Count: \(hkItems!.count)")}
        )
        
        healthKitInterface.readHealthData(startDate: beginDate, endDate: endDate,
                                          identifier: .stepCount, completion: { (hkItems, error) in
                                            DispatchQueue.main.async {
                                                
                                            self.yesterdaysVitals += hkItems!
                                            self.currentStatus.stepReady = true
                                            //self.uploadData.isEnabled = self.currentStatus.isReady()
                                                self.stepCount.text = "\(String(describing: hkItems!.count))"
                                            }
                                            print("Step Count: \(hkItems!.count)")}
        )
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // getYesterdayData()
        createDatePicker()
        createToolBar()
        addTextField()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func addTextField() {
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.0).isActive = true
        textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.0).isActive = true
        textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0).isActive = true
        textField.placeholder = "Select date"
        textField.borderStyle = .roundedRect
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        textField.text = dateFormatter.string(from: 1.day.ago()!)
        
        textField.inputView = datePicker
        
        textField.inputAccessoryView = toolBar
    }
    
    func createDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.date = 1.day.ago()!
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(datePicker:)), for: .valueChanged)
    }
    
    func createToolBar() {
        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        let todayButton = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(todayButtonPressed(sender:)))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(sender:)))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width/3, height: 40))
        label.text = "Choose your Date"
        let labelButton = UIBarButtonItem(customView:label)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([todayButton,flexibleSpace,labelButton,flexibleSpace,doneButton], animated: true)
    }
    
    @objc func todayButtonPressed(sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        textField.text = dateFormatter.string(from: Date())
        
        textField.resignFirstResponder()
    }
    
    @objc func doneButtonPressed(sender: UIBarButtonItem) {
        textField.resignFirstResponder()
    }
    
    @objc func datePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        textField.text = dateFormatter.string(from: datePicker.date)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
}
