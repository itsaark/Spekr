////
//  AppDelegate.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/14/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse
import Bolts
import Fabric
import DigitsKit
import TwitterKit
import FBSDKCoreKit
import ParseTwitterUtils
import ParseFacebookUtilsV4
import Crashlytics
import ReachabilitySwift




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var reachability : Reachability?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize Parse.
        Parse.setApplicationId("WdNnUtLLDaGtAZrmHPNnznjqaGNIDvORDDTobJkm", clientKey: "EnpTIbHvFwyHfNA4xwGSpkzpjqC7leQAV90GTIte")

        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        //Access for various objects
        let acl = PFACL()
        acl.setPublicReadAccess(true)
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        
        //Initializing Digits & Twitter
        Fabric.with([Digits.self, Twitter.self, Crashlytics.self])
        
        //PFUser.logOut()
        //Digits.sharedInstance().logOut()
        
        print(self.window?.rootViewController)
        
        //Initializing Twitter for Parse
        PFTwitterUtils.initializeWithConsumerKey("YcXiqliTkJPfilJmvx8LiMI2r",  consumerSecret:"Oy4EXN1X46tNdmtxLbusBqomQrzHgOasQUbXVUnc1T9CyHZrSb")
        //Initializing Facebook for Parse
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "reachabilityChanged:",
            name: ReachabilityChangedNotification,
            object: reachability)
        
        do{
            try reachability!.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }

        
        
                
        if let launchOptions = launchOptions as? [String : AnyObject] {
            if let notificationDictionary = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
                self.application(application, didReceiveRemoteNotification: notificationDictionary)
                
                if let aps = notificationDictionary["aps"] as? NSDictionary {
                    
                    if let alert = aps["alert"] as? NSString {
                        
                        if alert != "Someone near you just posted" {
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                            tabBarController.selectedIndex = 2
                            self.window?.rootViewController = tabBarController
                            
                            
                        } else{
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                                tabBarController.selectedIndex = 1
                                self.window?.rootViewController = tabBarController
                        }
                    }
                }
            }
        }

        
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func showSignInScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInNavigationViewController = storyboard.instantiateViewControllerWithIdentifier("SignInNavigationViewController") as! UINavigationController
        signInNavigationViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController?.presentViewController(signInNavigationViewController, animated: true, completion: nil)
        

    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Not reachable")
        }
    }
    
    func setMainTabBarControllerAsRoot() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
        //rootViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
    }
    

    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        application.registerForRemoteNotifications()
        print("Registered for remote notif")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()

        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.\n")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@\n", error)
        }
    }
    
    func clearBadges() {
        let installation = PFInstallation.currentInstallation()
        installation.badge = 0
        installation.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                print("cleared badges")
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
            else {
                print("failed to clear badges")
            }
        }
    }
    
        
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        if let aps = userInfo["aps"] as? NSDictionary {
            
            if let alert = aps["alert"] as? NSString {
                
                if alert != "Someone near you just posted" {
                    
                    if application.applicationState != .Active{
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                        tabBarController.selectedIndex = 2
                        self.window?.rootViewController = tabBarController
                        
                        
                    }else{
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                        self.window?.rootViewController = tabBarController
                        let tabArray = tabBarController.tabBar.items as NSArray!
                        let tabItem = tabArray.objectAtIndex(2) as! UITabBarItem
                        
                        if let badgeValue = (tabItem).badgeValue {
                            (tabItem).badgeValue = (Int(badgeValue)! + 1).description
                        } else {
                            (tabItem).badgeValue = "1"
                        }
                    }
                    
                } else{
                    
                    if application.applicationState != .Active{
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                        tabBarController.selectedIndex = 1
                        self.window?.rootViewController = tabBarController
                        
                    }
                }
            }
        }
        //PFPush.handlePush(userInfo)
        print("userInfo: \(userInfo)")
        
//          let storyboard = UIStoryboard(name: "Main", bundle: nil)
//          let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
//        
//          self.window?.rootViewController = tabBarController
//          tabBarController.tabBarItem.badgeValue = "1"
//        
//        let tabArray = tabBarController.tabBar.items as NSArray!
//        let tabItem = tabArray.objectAtIndex(2) as! UITabBarItem
//        
//        if let badgeValue = (tabItem).badgeValue {
//            (tabItem).badgeValue = (Int(badgeValue)! + 1).description
//        } else {
//            (tabItem).badgeValue = "1"
//        }
        
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
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
        FBSDKAppEvents.activateApp()
        
        clearBadges()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    

}

