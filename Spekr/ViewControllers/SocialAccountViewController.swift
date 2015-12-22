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
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    
    private func navigateToNewViewController(Identifier: String) {
        performSegueWithIdentifier(Identifier, sender: self)
    }
    
    // Updating twitter user data to Parse database
    func twitterUserDataToParse(){
        
        if PFTwitterUtils.isLinkedWithUser(PFUser.currentUser()!) {
            
            let screenName = PFTwitterUtils.twitter()?.screenName!
            let requestString = NSURL(string: "https://api.twitter.com/1.1/users/show.json?screen_name=" + screenName!)
            let request = NSMutableURLRequest(URL: requestString!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
            PFTwitterUtils.twitter()?.signRequest(request)
            let session = NSURLSession.sharedSession()
            
            // TODO: Add code to pull user's email ID from twitter API
            
            session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                print(data)
                print(response)
                print(error)
                
                if error == nil {
                    var result: AnyObject?
                    do {
                        result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    } catch let error2 as NSError? {
                        print("error 2 \(error2)")
                    }
                    
                    let userName: String! = result?.objectForKey("name") as! String
                    //let userEmail: String! = result?.objectForKey("email") as! String
                    
                    let myUser:PFUser = PFUser.currentUser()!
                    
                    // Save first name
                    if(userName != nil)
                    {
                        myUser.setObject(userName!, forKey: "displayName")
                        
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
                        
                        
                        myUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            
                            if(success) {
                                print("User details are now updated")
                            }
                            
                        })
                        
                        
                    }
                    
                    
                }
            }).resume()
        }
        
    }


    
    //TODO: Check if the user has already been linked
    //TODO: Update the linked account on parse

    @IBAction func linkTwitter(sender: AnyObject) {
        
        let user: PFUser = PFUser.currentUser()!
        
        if !PFTwitterUtils.isLinkedWithUser(user) {
            PFTwitterUtils.linkUser(user, block: {
                (succeeded: Bool?, error: NSError?) -> Void in
                if error == nil {
                    
                if PFTwitterUtils.isLinkedWithUser(user) {
                    print("Woohoo, user logged in with Twitter!")
                    self.twitterUserDataToParse()
                    self.navigateToNewViewController("JumpFromLinkToLocalFeed")
                    
                    }
                } else {
                    
                    if let error = error {
                        
                        let errorString = error.userInfo["error"] as? NSString
                        print("Error: \(errorString)")
                    }
                    
                }
            })
        } else {
            
            print("another user is linked")
        }

        
    }
    
    // Updating Facebook user data to Parse database
    func fbUserDataToParse() {
        
        let requestParameters = ["fields": "id, email, name"]
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
            }
            else
            {
                let userId:String = result["id"] as! String
                let userName:String? = result["name"] as? String
                let userEmail:String? = result["email"] as? String
                
                
                print("\(userEmail)")
                
                let myUser:PFUser = PFUser.currentUser()!
                
                // Save first name
                if(userName != nil)
                {
                    myUser.setObject(userName!, forKey: "displayName")
                    
                }
                
                // Save email address
                if(userEmail != nil)
                {
                    myUser.setObject(userEmail!, forKey: "email")
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
                    
                    
                    myUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                        if(success) {
                            print("User details are now updated")
                        }
                        
                    })
                    
                    
                    
                }
                
                
                
            }
        })
    }

    
    //TODO: Check if the user has already been linked

    @IBAction func linkFacebook(sender: AnyObject) {
        
        let user: PFUser = PFUser.currentUser()!
        
        if !PFFacebookUtils.isLinkedWithUser(user) {
            PFFacebookUtils.linkUserInBackground(user, withReadPermissions: nil, block: {
                (succeeded: Bool?, error: NSError?) -> Void in
                
                if error == nil{
                
                if (succeeded != nil) {
                    print("Woohoo, the user is linked with Facebook!")
                    
                    self.fbUserDataToParse()
                    self.navigateToNewViewController("JumpFromLinkToLocalFeed")
                }
                } else {
                    
                    if let error = error {
                        let errorString = error.userInfo["error"] as? NSString
                        print("Error: \(errorString)") }
                }
            })
                
        } else {
            
            print("another user is linked")
        }
    }
    
    
}
