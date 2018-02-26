//
//  TableViewController.swift
//  YanYu-prj-iBeacon
//
//  Created by 洪權甫 on 2018/2/21.
//  Copyright © 2018年 洪權甫. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation
import CoreData

class TableViewController: UITableViewController, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {

    
    let app = UIApplication.shared.delegate as! AppDelegate
    let lm = CLLocationManager()
    
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
        var uuid:UUID!
        var region:CLBeaconRegion!
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.Therebegin(_:)), name: Notification.Name("Therebegin"), object: nil)
        
        guard UserDefaults.standard.bool(forKey: "session") else{
            if let LoginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? ViewController{
                present(LoginViewController, animated: true, completion: nil)
            }
            return
        }
        
        
        fetchRequest.sortDescriptors = [sort]
        
        viewContext = app.persistentContainer.viewContext
        fetchResultController = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        if CLLocationManager.isRangingAvailable() {
            lm.requestAlwaysAuthorization()
        }
        
        lm.delegate = self
        
        uuid = UUID(uuidString: "B5B182C7-EAB1-4988-AA99-B5C1517008D9")
        region = CLBeaconRegion(proximityUUID: uuid!, identifier: "YanYu" )
//        lm.stopMonitoring(for: region)
        lm.startMonitoring(for: region)
        lm.startRangingBeacons(in: region)
        
        
        
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
        
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
//            self.Therebegin()
//        }

    }
    @IBAction func LoginOut(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "session")
        viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        isThere = Array<Bool>.init(repeating: false, count: ibeacon.count)
        
        return ibeacon.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell

        extractedFunc1(cell, indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
        
    }
    
    // touch row
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        //        cell.alpha = 1
        UIView.animate(withDuration: 0.2, animations: {
            //            self.cardView.backgroundColor = .brown
            cell.cardView.bounds.size.width /= 0.98
            cell.cardView.bounds.size.height /= 0.98
        }, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath){
        
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        //        cell.alpha = 0.3
        UIView.animate(withDuration: 0.2, animations: {
            //            self.cardView.backgroundColor = .brown
            cell.cardView.bounds.size.width *= 0.98
            cell.cardView.bounds.size.height *= 0.98
            //            self.cardView.frame.size.width *= 0.8
            //            self.cardView.frame.size.height *= 0.8
        }, completion: nil)
        
    }
    
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
        NotificationCenter.default.post(name: NSNotification.Name("Therebegin"), object: tigger)
        tigger += 1
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
    
    
    /*---------------------------------------------CoreData----------------------------------------------------*/
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
        self.tableView.beginUpdates()
        print("controllerWillChange")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            print("update")
//        case .insert:
//
//        case .move:
//
//        case .delete:
            
        default:
            print("default")
        }
        if let fetchedObjects = controller.fetchedObjects {
            ibeacon = fetchedObjects as! [Beacon]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
/*---------------------------------------------END CoreData----------------------------------------------------*/
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
    
    fileprivate func extractedFunc1(_ cell: TableViewCell, _ indexPath: IndexPath) {
        
        cell.ID.text = "報表編號 : \(String(ibeacon[indexPath.row].reportID) )"
        cell.Name.text = "報表名稱 : \(ibeacon[indexPath.row].reportName ?? "無資料")"
        cell.Body.text = "報表內容 : \(ibeacon[indexPath.row].reportBody ?? "無資料")"
        cell.Location.text = "地區 : \(ibeacon[indexPath.row].iBeacon_Location ?? "無資料")"
        
        extractedFunc2(cell, indexPath)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
    }

    fileprivate func extractedFunc2(_ cell: TableViewCell, _ indexPath: IndexPath) {
        
            self.ThereModel_j(indexPath: indexPath)
            cell.New.text = ThereModel.Location
            cell.view.backgroundColor = ThereModel.backgriundColor
            cell.isUserInteractionEnabled = ThereModel.isUserInteractionEnabled
        
    }
    
    func ThereModel_j (indexPath: IndexPath){
        ThereModel.Location = "是否到達位置 : \(isThere[indexPath.row] ? "是" : "否") \(indexPath.row)"
        ThereModel.backgriundColor = isThere[indexPath.row] ? UIColor.blue : UIColor.white
        ThereModel.isUserInteractionEnabled = isThere[indexPath.row]
    }
    
    @objc func Therebegin(_ notification : Notification){
        
        if let num = notification.object as? Int {
            print(num)
            if num > 10 {
                print(isThere)
                tigger = 0
                var indexPath : IndexPath
                for index in 0 ... isThere.count-1 {
                    
                    indexPath = IndexPath.init(row: index , section: 0)
                    if let cell = tableView.cellForRow(at: indexPath) as? TableViewCell {
                        extractedFunc2(cell,indexPath)
                    }
                    
                    
                }
            }
        }
        
        if notification.object is IndexPath {
            let indexPath = notification.object as! IndexPath
            
            if let cell = tableView.cellForRow(at: indexPath) as? TableViewCell {
                extractedFunc2(cell,indexPath)
            }
        }
        isThere_indexPath.removeAll()
        
    }
    
    
    
}
