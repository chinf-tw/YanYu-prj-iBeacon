//
//  AppDelegate.swift
//  YanYu-prj-iBeacon
//
//  Created by 洪權甫 on 2018/2/21.
//  Copyright © 2018年 洪權甫. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var isLogin = UserDefaults.standard.bool(forKey: "session")
    let lm = CLLocationManager()
    var uuid:UUID!
    var region:CLBeaconRegion!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
        if CLLocationManager.isRangingAvailable() {
            lm.requestAlwaysAuthorization()
        }
        
        if isLogin {
            let controller = UIStoryboard(name: "List",bundle: nil).instantiateViewController(withIdentifier: "List")
            self.window?.rootViewController = controller
        }else{
            let controller = UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "LoginController")
            self.window?.rootViewController = controller
        }
        
        lm.delegate = self
        
        uuid = UUID(uuidString: "B5B182C7-EAB1-4988-AA99-B5C1517008D9")
        region = CLBeaconRegion(proximityUUID: uuid!, identifier: "nil" )
        lm.stopMonitoring(for: region)
        region = CLBeaconRegion(proximityUUID: uuid!, identifier: "YanYu" )
        lm.stopMonitoring(for: region)
        lm.startMonitoring(for: region)
//                lm.startRangingBeacons(in: region)
        
        return true
    }

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
            print("inside \(region.identifier)")
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
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "YanYu_prj_iBeacon")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

