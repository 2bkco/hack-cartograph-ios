//
//  AppDelegate.swift
//  cartograph2
//
//  Created by Jed Lau on 11/25/14.
//  Copyright (c) 2014 Jed Lau. All rights reserved.
//

import Photos
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var previousFetchResult: PHFetchResult?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
            })
        }

        // Ask to send local notifications.
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil))

        // Set the minimum background fetch interval.
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized {
            var currentFetchResult = PHCollectionList.fetchMomentListsWithSubtype(PHCollectionListSubtype.MomentListCluster, options: nil);
            
            if self.previousFetchResult != nil {
                // Compare against previous fetch results.
                var fetchResultChangeDetails = PHFetchResultChangeDetails(fromFetchResult:self.previousFetchResult, toFetchResult:currentFetchResult, changedObjects:nil)
                
                self.previousFetchResult = currentFetchResult
                
                if fetchResultChangeDetails.hasIncrementalChanges {
                    // Get new moments.
                    
                    // Call backend to determine if any moments may be shared.
                    
                    presentLocalNotification()
                    completionHandler(UIBackgroundFetchResult.NewData)
                    return
                }
            } else {
                // No previous fetch result.
                if currentFetchResult.count > 0 {
                    presentLocalNotification()
                    completionHandler(UIBackgroundFetchResult.NewData)
                    return
                }
            }
        }

        completionHandler(UIBackgroundFetchResult.NoData)
    }
    
    func presentLocalNotification() {
        dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
            // Display a location notification.
            var localNotification:UILocalNotification = UILocalNotification()
            localNotification.alertBody = "Did you see nicoco, hechanova, or 3 other friends yesterday?"
            localNotification.alertAction = "view detected moments"
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        })
    }

}

