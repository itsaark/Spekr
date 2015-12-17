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
    
    @IBAction func linkTwitter(sender: AnyObject) {
        
        let user: PFUser = PFUser.currentUser()!
        
        if !PFTwitterUtils.isLinkedWithUser(user) {
            PFTwitterUtils.linkUser(user, block: {
                (succeeded: Bool?, error: NSError?) -> Void in
                if PFTwitterUtils.isLinkedWithUser(user) {
                    print("Woohoo, user logged in with Twitter!")
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

    
    
    @IBAction func linkFacebook(sender: AnyObject) {
        
        let user: PFUser = PFUser.currentUser()!
        
        if !PFFacebookUtils.isLinkedWithUser(user) {
            PFFacebookUtils.linkUserInBackground(user, withReadPermissions: nil, block: {
                (succeeded: Bool?, error: NSError?) -> Void in
                if (succeeded != nil) {
                    print("Woohoo, the user is linked with Facebook!")
                    
                    self.fbUserDataToParse()
                }
            })
        } else {
            
            print("another user is linked")
        }
    }
    
    
}
