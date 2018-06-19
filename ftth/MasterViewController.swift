//
//  MasterViewController.swift
//  ftth
//
//  Created by Schappet, James C on 5/31/18.
//  Copyright © 2018 Schappet.com. All rights reserved.
//

import UIKit
import SwiftDate

class MasterViewController: UITableViewController {

    let cal = Calendar(identifier: .gregorian)

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()

    // HealthKit setup
    let healthKitInterface = HealthKitInterface()
    var yesterdaysVitals = [HealthItem]()
    
    func getYesterdayData() {
        
        let oneWeekAgo: Date = 2.days.ago()!
        
        let oneDayAgo: Date = 1.days.ago()!
        
        let beginDate = cal.startOfDay(for: oneWeekAgo)
        let endDate = cal.startOfDay(for: oneDayAgo)
        
        healthKitInterface.readHealthData(startDate: beginDate, endDate: endDate,
                                          identifier: .heartRate, completion: { (hkItems, error) in
                                            self.yesterdaysVitals += hkItems!
                                            print("Heart Rate Count: \(hkItems!.count)")}
        )
        
        healthKitInterface.readHealthData(startDate: beginDate, endDate: endDate,
                                          identifier: .bodyMass, completion: { (hkItems, error) in
                                            self.yesterdaysVitals += hkItems!
                                            print("Weight Count: \(hkItems!.count)")}
        )
        
        healthKitInterface.readHealthData(startDate: beginDate, endDate: endDate,
                                          identifier: .stepCount, completion: { (hkItems, error) in
                                            self.yesterdaysVitals += hkItems!
                                            print("Step Count: \(hkItems!.count)")}
        )
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
        
        getYesterdayData()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func insertNewObject(_ sender: Any) {
        let client =  MyDbClient()
        client.createDocument()
        
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

