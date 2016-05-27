//
//  AppDelegate.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/15/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let url = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!.URLByAppendingPathComponent("StoredData.sqlite")
        if url.checkResourceIsReachableAndReturnError(nil) == false {
            try! NSFileManager.defaultManager().copyItemAtURL(NSBundle.mainBundle().URLForResource("StoredData", withExtension: "sqlite")!, toURL: url)
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        try! DataManager.sharedManager.managedObjectContext.save()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

