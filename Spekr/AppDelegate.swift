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




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


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
        
        print("currentuser: \(PFUser.currentUser())")
        
        //TODO: Add a similar instance for facebook as well.
        // Check for an existing Twitter or Digits session before presenting the sign in screen.
//        if Twitter.sharedInstance().sessionStore.session() == nil && Digits.sharedInstance().session() == nil && FBSDKAccessToken.currentAccessToken() == nil{
//            
//            showSignInScreen()
//            
//        }
        
        //let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
        //application.registerUserNotificationSettings(settings)
        //application.registerForRemoteNotifications()
        
//        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
//        let launchViewController = storyboard.instantiateViewControllerWithIdentifier("launchScreen")
//        
//        self.window?.rootViewController = launchViewController
        
                
        if let launchOptions = launchOptions as? [String : AnyObject] {
            if let notificationDictionary = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
                self.application(application, didReceiveRemoteNotification: notificationDictionary)
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
        
        //self.window?.rootViewController = signInNavigationViewController as? UINavigationController
        //            UIView.transitionWithView(window!, duration: 0.1, options: .TransitionCrossDissolve, animations: { () -> Void in
        //
        //
        //
        //                }, completion: nil)
    }
    
    func logOutButtonTapped(){
        
        PFUser.logOut()
        Digits.sharedInstance().logOut()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
        self.window?.rootViewController = tabBarController
        
        showSignInScreen()
        
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
        print("fucking work device")
        
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
        PFPush.handlePush(userInfo)
        print("userInfo: \(userInfo)")
        
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
        
          self.window?.rootViewController = tabBarController
          tabBarController.tabBarItem.badgeValue = "1"
        
        let tabArray = tabBarController.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(2) as! UITabBarItem
        
        if let badgeValue = (tabItem).badgeValue {
            (tabItem).badgeValue = (Int(badgeValue)! + 1).description
        } else {
            (tabItem).badgeValue = "1"
        }
        
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

