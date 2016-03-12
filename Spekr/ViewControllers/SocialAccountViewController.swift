//
//  FirstLastNameViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/15/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import ParseTwitterUtils



class SocialAccountViewController: UIViewController {
    
    override func viewDidLoad() {
        
        navigationController?.navigationBarHidden = true
    }
    
    //Displays error messages
    let alert = SweetAlert()
    
    
    //Funtion for seguing from one view controller to other
    private func navigateToNewViewController(Identifier: String) {
        performSegueWithIdentifier(Identifier, sender: self)
    }
    
    func loadTabBarViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
        
        self.presentViewController(tabBarController, animated: true, completion: nil)
        
    }
    
    // Updating twitter user data to Parse database
    func twitterUserDataToParse(completionBlock: PFBooleanResultBlock){
        
        if PFTwitterUtils.isLinkedWithUser(PFUser.currentUser()!) {
            
            let screenName = PFTwitterUtils.twitter()?.screenName!
            let requestString = NSURL(string: "https://api.twitter.com/1.1/users/show.json?screen_name=" + screenName!)
            let request = NSMutableURLRequest(URL: requestString!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
            PFTwitterUtils.twitter()?.signRequest(request)
            let session = NSURLSession.sharedSession()
            
            // TODO: Add code to pull user's email ID from twitter API
            
            session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                
                if error == nil {
                    var result: AnyObject?
                    do {
                        result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    } catch let error2 as NSError? {
                        print("error 2 \(error2)")
                    }
                    
                    let userName: String! = result?.objectForKey("name") as! String
                    //let userEmail: String! = result?.objectForKey("email") as! String
                    
                    let userId: String! = result?.objectForKey("id_str") as! String
                    
                    let userProfileLink: String! = "https://twitter.com/intent/user?user_id=" + userId
                    
                    let myUser:PFUser = PFUser.currentUser()!
                    
                    // Save first name
                    if(userName != nil)
                    {
                        myUser.setObject(userName!, forKey: "displayName")
                        
                    }
                    
                    // Save user profile link
                    if(userProfileLink != nil)
                    {
                        myUser.setObject(userProfileLink!, forKey: "link")
                        
                    }
                    
                    // Save email address
                    //if(userEmail != nil)
                    //{
                    // myUser.setObject(userEmail!, forKey: "email")
                    //}
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        
                        let urlString = result?.objectForKey("profile_image_url_https") as! String
                        let hiResUrlString = urlString.stringByReplacingOccurrencesOfString("_normal", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        let twitterPhotoUrl = NSURL(string: hiResUrlString)
                        let profilePictureData = NSData(contentsOfURL: twitterPhotoUrl!)
                        
                        if(profilePictureData != nil)
                        {
                            let profileFileObject = PFFile(data:profilePictureData!)
                            myUser.setObject(profileFileObject!, forKey: "displayImage")
                        }
                        
                        myUser.saveInBackgroundWithBlock(completionBlock)
                        
                    }
                    
                    
                }
            }).resume()
        }
        
    }


    //TODO: Check if the user has already been linked
    //TODO: Update the linked account on parse
    
    //Link Twitter button tapped
    @IBAction func linkTwitter(sender: AnyObject) {
        
        let user: PFUser = PFUser.currentUser()!
        
        if !PFTwitterUtils.isLinkedWithUser(user) {
            PFTwitterUtils.linkUser(user, block: {
                (succeeded: Bool?, error: NSError?) -> Void in
                if error == nil {
                    
                if PFTwitterUtils.isLinkedWithUser(user) {
                    print("Woohoo, user logged in with Twitter!")
                    ParseHelper.createUserDetailsInstance()
                    self.twitterUserDataToParse({ (updated: Bool, error: NSError?) -> Void in
                        
                        if updated {
                            
                            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                                appDelegate.setMainTabBarControllerAsRoot()
                            }
                        }
                    })
                    
                    }
                } else {
                    
                    if let error = error {
                        
                        if let errorString = error.userInfo["error"] as? NSString {
                            
                            self.alert.showAlert("Error", subTitle: (errorString as String) + ".Please try again.", style: .Error, buttonTitle: "OK")
                        }
                        
                    }
                    
                }
            })
        } else {
            
            self.alert.showAlert("Account already linked", subTitle: "Please try with a different account.", style: AlertStyle.Error, buttonTitle: "OK")
        }

        
    }
    
    // Updating Facebook user data to Parse database
    func fbUserDataToParse(completionBlock: PFBooleanResultBlock) {
        
        let requestParameters = ["fields": "id, email, name, link"]
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                if let error = error {
                    
                    if let errorString = error.userInfo["error"] as? NSString{
                        
                        self.alert.showAlert("Error", subTitle: errorString as String + ".Please try again.", style: .Error, buttonTitle: "OK")
                    }
                }
            }
            else
            {
                let userId:String = result["id"] as! String
                let userName:String? = result["name"] as? String
                let userTimeLineLink:String? = result["link"] as? String
                
                SVProgressHUD.setForegroundColor(UIColor(red: 58, green: 197, blue: 105))
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Gradient)
                SVProgressHUD.showWithStatus("Getting there")
                
                let myUser:PFUser = PFUser.currentUser()!
                
                // Save name
                if(userName != nil)
                {
                    myUser.setObject(userName!, forKey: "displayName")
                    
                }
                
                
                // Save Timeline link
                if(userTimeLineLink != nil)
                {
                    myUser.setObject(userTimeLineLink!, forKey: "link")
                }
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    // Get Facebook profile picture
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    
                    let profilePictureUrl = NSURL(string: userProfile)
                    
                    let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                    
                    if(profilePictureData != nil)
                    {
                        let profileFileObject = PFFile(data:profilePictureData!)
                        myUser.setObject(profileFileObject!, forKey: "displayImage")
                    }
                    
                    
                    myUser.saveInBackgroundWithBlock(completionBlock)
                    
                    dispatch_async(dispatch_get_main_queue()){
                        
                        SVProgressHUD.dismiss()
                    }
                    
                }
                
                
                
            }
        })
    }

    
    //TODO: Check if the user has already been linked

    //Link Facebook button tapped
    @IBAction func linkFacebook(sender: AnyObject) {
        
        let user: PFUser = PFUser.currentUser()!
        
        if !PFFacebookUtils.isLinkedWithUser(user) {
            PFFacebookUtils.linkUserInBackground(user, withReadPermissions: nil, block: {
                (succeeded: Bool?, error: NSError?) -> Void in
                
                if error == nil{
                
                if (succeeded != nil) {
                    print("Woohoo, the user is linked with Facebook!")
                    ParseHelper.createUserDetailsInstance()
                    self.fbUserDataToParse({ (updated: Bool, error: NSError?) -> Void in
                        
                        if updated {
                            
                            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                                appDelegate.setMainTabBarControllerAsRoot()
                            }
                        }
                    })
                    

                }
                } else {
                    
                    if let error = error {
                        
                        if let errorString = error.userInfo["error"] as? NSString {
                            
                            self.alert.showAlert("Error", subTitle: errorString as String + ".Please try again.", style: .Error, buttonTitle: "OK")
                        }
                    }
                        
                }
            })
                
        } else {
            
            self.alert.showAlert("Account already linked", subTitle: ".Please try with a different account.", style: AlertStyle.Error, buttonTitle: "OK")
        }
    }
    
    
}
