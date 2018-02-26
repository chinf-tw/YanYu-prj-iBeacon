//
//  ReportViewController.swift
//  YanYu-prj-iBeacon
//
//  Created by 洪權甫 on 2018/2/26.
//  Copyright © 2018年 洪權甫. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation
import CoreData

class ReportViewController: UIViewController{
    
    let app = UIApplication.shared.delegate as! AppDelegate
    let lm = CLLocationManager()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var actit: UIActivityIndicatorView!
    @IBOutlet weak var ibeacon_seatch: UIBarButtonItem!
    var ibeacon: [Beacon] = []
    var isThere_indexPath: Set<IndexPath> = []
    var viewContext: NSManagedObjectContext!
    var fetchResultController: NSFetchedResultsController<Beacon>!
    var isThere: [Bool] = []
    var tigger = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let Report = "http://yanyu-chinf.azurewebsites.net/api/report"
        let reportField = ["ID","reportname","reportbody","iBeacon_Location","ReportUUID","major","minor"]
        
        let fetchRequest: NSFetchRequest<Beacon> = Beacon.fetchRequest()
        let sort = NSSortDescriptor(key: "reportID", ascending: true)
        
        var dataString = ""
        var dataString2 = ""
        var data: Data
        
        
        guard UserDefaults.standard.bool(forKey: "session") else{
            if let LoginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? ViewController{
                present(LoginViewController, animated: true, completion: nil)
            }
            return
        }
        
        
        fetchRequest.sortDescriptors = [sort]
        
        viewContext = app.persistentContainer.viewContext
        
        if CLLocationManager.isRangingAvailable() {
            lm.requestAlwaysAuthorization()
        }
        
        lm.delegate = self
        
        
        //        lm.stopMonitoring(for: region)
        
        
        
        
        reportField.forEach { (value) in
            dataString += value + ","
        }
        dataString2 = "data=" + String(dataString[..<dataString.index(before: dataString.endIndex)])
        data = dataString2.data(using: .utf8)!
        
        
        
        
        
        //        extractedFunc(Report, data,reportField)
        if let fetch = try? self.viewContext.fetch(fetchRequest), !(fetch.isEmpty) {
            ibeacon = fetch
            print("---place---")
            self.ibeacon.forEach({ (beacon) in
                print(beacon.reportID)
            })
        }else{
            extractedFunc(Report, data,reportField)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func iBeacon_search(_ sender: Any) {
        let uuid = UUID(uuidString: "B5B182C7-EAB1-4988-AA99-B5C1517008D9")
        let region = CLBeaconRegion(proximityUUID: uuid!, identifier: "YanYu" )
        lm.startRangingBeacons(in: region)
        actit.center = view.center
        actit.startAnimating()
        ibeacon_seatch.isEnabled = false
        ibeacon_seatch.title = "尋找中"
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            self.actit.stopAnimating()
            self.lm.stopRangingBeacons(in: region)
            self.ibeacon_seatch.isEnabled = true
            self.ibeacon_seatch.title = "尋找"
            self.Therebegin()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    fileprivate func extractedFunc(_ Report: String, _ data: Data?, _ Field: Array<String>) {
        var ListData:[String:Array<String>] = [:]
        DataTask.init().requestWithModel(stringURL: Report, httpBody: data!, model: Model.HTTP.POST, completion: { (json) in
            ListData = JsonData().getData(json: json)!
            var user:Beacon
            
            do {
                let beacons = try self.viewContext.fetch(Beacon.fetchRequest())
                for beacon in beacons as! [Beacon] {
                    self.viewContext.delete(beacon)
                }
                self.app.saveContext()
            }catch {
                
            }
            
            for index in 0 ... ((ListData.first?.value.count)!-1) {
                user = NSEntityDescription.insertNewObject(forEntityName: "Beacon", into: self.viewContext) as! Beacon
                //                user.reportID = self.ListData[Field[0]]![index]
                user.setValue(Int(ListData[Field[0]]![index]), forKey: "reportID")
                user.reportName = ListData[Field[1]]![index]
                user.reportBody = ListData[Field[2]]![index]
                user.iBeacon_Location = ListData[Field[3]]![index]
                user.reportUUID = UUID(uuidString: ListData[Field[4]]![index])
                user.major = ListData[Field[5]]![index]
                user.minor = ListData[Field[6]]![index]
                
                
            }
            self.app.saveContext()
            do{
                let fetchRequest: NSFetchRequest<Beacon> = Beacon.fetchRequest()
                let sort = NSSortDescriptor(key: "reportID", ascending: true)
                fetchRequest.sortDescriptors = [sort]
                self.ibeacon = try self.viewContext.fetch(fetchRequest)
                self.ibeacon.forEach({ (beacon) in
                    print(beacon.reportID)
                })
            }catch{
                
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        })
    }
    
    fileprivate func extractedFunc1(_ cell: ReportTableViewCell, _ indexPath: IndexPath) {
        
        cell.reportID.text = "編號 : \(ibeacon[indexPath.row].reportID)"
        cell.ReportTitle.text = ibeacon[indexPath.row].reportName
        cell.reportBody.text = ibeacon[indexPath.row].reportBody
        cell.reportLocation.text = ibeacon[indexPath.row].iBeacon_Location
        
        extractedFunc2(cell, indexPath)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    fileprivate func extractedFunc2(_ cell: ReportTableViewCell, _ indexPath: IndexPath) {
        
        cell.isStatus(isThere[indexPath.row])
        
        cell.isUserInteractionEnabled = isThere[indexPath.row]
        
    }
    
    
    
    func Therebegin(){
        
        print(isThere)
        tigger = 0
        var indexPath : IndexPath
        for index in 0 ... isThere.count-1 {
            
            indexPath = IndexPath.init(row: index , section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ReportTableViewCell {
                extractedFunc2(cell,indexPath)
            }
        }
        isThere_indexPath.removeAll()
        
    }

}

extension ReportViewController: UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        isThere = Array<Bool>.init(repeating: false, count: ibeacon.count)
        
        return ibeacon.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReportTableViewCell
        
        extractedFunc1(cell, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    // touch row
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ReportTableViewCell
        //        cell.alpha = 1
        UIView.animate(withDuration: 0.2, animations: {
            //            self.cardView.backgroundColor = .brown
            cell.cardView.bounds.size.width /= 0.98
            cell.cardView.bounds.size.height /= 0.98
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath){
        
        let cell = tableView.cellForRow(at: indexPath) as! ReportTableViewCell
        //        cell.alpha = 0.3
        UIView.animate(withDuration: 0.2, animations: {
            //            self.cardView.backgroundColor = .brown
            cell.cardView.bounds.size.width *= 0.98
            cell.cardView.bounds.size.height *= 0.98
            //            self.cardView.frame.size.width *= 0.8
            //            self.cardView.frame.size.height *= 0.8
        }, completion: nil)
        
    }
}

extension ReportViewController: CLLocationManagerDelegate {
    /*---------------------------------------------iBeacon----------------------------------------------------*/
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if ibeacon.count > 1 {
            isThere.removeAll()
            isThere = Array<Bool>.init(repeating: false, count: ibeacon.count)
            for beacon in beacons {
                
                ibeacon.forEach({ (ibeacon) in
                    if ibeacon.reportUUID == beacon.proximityUUID, ibeacon.major == beacon.major.stringValue, ibeacon.minor == beacon.minor.stringValue {
                        let index = ibeacon.reportID.hashValue - 1
                        let indexPath = IndexPath.init(row: index , section: 0)
                        
                        isThere_indexPath.insert(indexPath)
                        isThere[index] = true
                        //                        print(ibeacon.reportID)
                    }
                })
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            print("inside \(region.identifier)")
            if region is CLBeaconRegion {
                // Start ranging only if the feature is available.
                if CLLocationManager.isRangingAvailable() {
                    manager.startRangingBeacons(in: region as! CLBeaconRegion)
                    
                    // Store the beacon so that ranging can be stopped on demand.
                    //                beaconsToRange.append(region as! CLBeaconRegion)
                }
            }
        case .outside:
            print("outside \(region.identifier)")
        case .unknown:
            print("unknown \(region.identifier)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if region is CLBeaconRegion {
            // Start ranging only if the feature is available.
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
                
                // Store the beacon so that ranging can be stopped on demand.
                //                beaconsToRange.append(region as! CLBeaconRegion)
            }
        }
        print("Enter \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit \(region.identifier)")
    }
    
    /*---------------------------------------------END iBeacon----------------------------------------------------*/
}
