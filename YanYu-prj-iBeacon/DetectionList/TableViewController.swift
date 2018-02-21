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

class TableViewController: UITableViewController, CLLocationManagerDelegate {

    var ListData:[String:Array<String>] = [:]
    var List:[[String:String]] = []
    
    let lm = CLLocationManager()
    var uuid:UUID!
    var Name:String!
    var region:CLBeaconRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard UserDefaults.standard.bool(forKey: "session") else{
            if let LoginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? ViewController{
                present(LoginViewController, animated: true, completion: nil)
            }
            return
        }
        
        
        let Report = "http://yanyu-chinf.azurewebsites.net/api/report"
        let data = "data=ID,reportname,reportbody".data(using: .utf8)
        
        DataTask.init().requestWithModel(stringURL: Report, httpBody: data!, model: Model.HTTP.POST, completion: { (json) in
            self.ListData = JsonData().getData(json: json)!
            
            for index in 0 ... (self.ListData.count-1) {
                self.List.append([:])
                for (key,value) in self.ListData {
                    self.List[index][key] = value[index]
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        
        lm.requestAlwaysAuthorization()
        lm.delegate = self
        
        uuid = UUID(uuidString: "B5B182C7-EAB1-4988-AA99-B5C1517008D9")
        
        region = CLBeaconRegion(proximityUUID: uuid!, identifier: Name ?? "nil" )
        
        lm.startMonitoring(for: region)
        //        lm.startRangingBeacons(in: region)

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
        return List.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell

        cell.ID.text = "報表編號 : \(List[indexPath.row]["ID"]!)"
        cell.Name.text = "報表名稱 : \(List[indexPath.row]["reportname"]!)"
        cell.Body.text = "報表內容 : \(List[indexPath.row]["reportbody"]!)"

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    // touch row
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        //        cell.alpha = 1
        UIView.animate(withDuration: 0.1, animations: {
            //            self.cardView.backgroundColor = .brown
            cell.cardView.bounds.size.width /= 0.98
            cell.cardView.bounds.size.height /= 0.98
            //            self.cardView.frame.size.width *= 0.8
            //            self.cardView.frame.size.height *= 0.8
        }, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath){
        
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        //        cell.alpha = 0.3
        UIView.animate(withDuration: 0.1, animations: {
            //            self.cardView.backgroundColor = .brown
            cell.cardView.bounds.size.width *= 0.98
            cell.cardView.bounds.size.height *= 0.98
            //            self.cardView.frame.size.width *= 0.8
            //            self.cardView.frame.size.height *= 0.8
        }, completion: nil)
    }

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

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        
        for beacon in beacons {
            print("\n major = \(beacon.major), minor = \(beacon.minor), accuracy = \(beacon.accuracy), rssi = \(beacon.rssi)")
//            switch beacon.proximity {
//            case .far:
//                textLabel.text! += "\n beacon 距離遠"
//            case .near:
//                textLabel.text! += "\n beacon 距離近"
//            case .unknown:
//                textLabel.text! += "\n beacon 距離未知"
//            case .immediate:
//                textLabel.text! += "\n beacon 就在旁邊"
//            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            print("inside")
        case .outside:
            print("outside")
        case .unknown:
            print("unknown")
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
        let alertController = UIAlertController(title: "iBeacon消息", message: "已進入iBeacon範圍內", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alertController,animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit \(region.identifier)")
        let alertController = UIAlertController(title: "iBeacon消息", message: "已離開iBeacon範圍", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alertController,animated: true, completion: nil)
    }
    
    
}
