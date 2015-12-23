//
//  SignInViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/14/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import DigitsKit
import Parse
import ParseTwitterUtils
import ParseFacebookUtilsV4
import TwitterKit





class SignInViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        
        
        navigationController?.navigationBarHidden = true
    }
    
    //Displaying error message through Alert
    func DisplayAert(title:String, errorMessage:String){
        
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    //Segue funtion
    private func navigateToNewViewController(Identifier: String) {
        performSegueWithIdentifier(Identifier, sender: self)
    }

    // Updating Facebook user data to Parse database
    func digitsUserDataToParse() {
        
    }
    
    //Sign in with Phone Number
    @IBAction func didTapPhoneSignInButton(sender: AnyObject) {
        
   
        
        PFUser.loginWithDigitsInBackground { (user: PFUser?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let user = user {
                    
                if user.isLinkedWithAuthType("facebook") || user.isLinkedWithAuthType("twitter") {
                    
                    //TODO: Change the string in this func to "JumpFromSignInToLocalFeed" when isNew property is added.
                    self.navigateToNewViewController("JumpFromSignInToLocalFeed")

                    
                }else {
                    //TODO: Change the string in this func to "JumpFromSignInToLocalFeed" when isNew property is added.
                    self.navigateToNewViewController("JumpFromPhoneSignInToLinkAccount")
                    
                    }
                }
            
            print("log in done")
            
            // TODO: Perform a segue to user profile screen after successful sign in
            // Navigate to the Naming screen.
            
            } else {
                
                if let error = error {
                    
                    if let errorString = error.userInfo["error"] as? NSString {
                        
                        self.DisplayAert("Error", errorMessage: errorString as String)
                    }
                    
                }
            }

        }

        
            
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
        
    //Sign in with Twitter     
    @IBAction func signInTwitter(sender: AnyObject) {
        
        PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if error == nil {
                if let user = user {
                    if user.isNew {
                    print("User signed up and logged in with Twitter!")
                        
//                        
//                        let shareEmailViewController = TWTRShareEmailViewController() { email, error in
//                            print("Email \(email), Error: \(error)")
//                        }
//                    self.presentViewController(shareEmailViewController, animated: true, completion: { () -> Void in
//                        
//                        self.twitterUserDataToParse()
//                    })
//                    
                        
                    } else {
                        print("User logged in with Twitter!")
                    }
                
                
                
                        //Performing a segue to Local Feed Screen
                        self.navigateToNewViewController("JumpFromSignInToLocalFeed")
                
                
                } else {
                    print("Uh oh. The user cancelled the Twitter login.")
                       }
            } else {
                if let error = error {
                    if let errorString = error.userInfo["error"] as? NSString {
                        
                        self.DisplayAert("Error", errorMessage: errorString as String)
                    }
                }
            }
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
    
    //Sign in with Facebook
    @IBAction func signInFacebook(sender: AnyObject) {
        
        let permissions = ["public_profile", "email"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            
            if error != nil {
                //Display an alert message
                if let error = error {
                    if let errorString = error.userInfo["error"] as? NSString {
                        
                        self.DisplayAert("Error", errorMessage: errorString as String)
                    }
                }
                
            } else {
                
                if let user = user {
                    if user.isNew {
                        print("User signed up and logged in through Facebook!")
                        
                        self.fbUserDataToParse()
                        
                    } else {
                        print("User logged in through Facebook!")
                    }
                    
                    //Performing a segue to Local Feed Screen
                    self.navigateToNewViewController("JumpFromSignInToLocalFeed")
                    
                } else {
                    print("Uh oh. The user cancelled the Facebook login.")
                }
                
            }
            
        }

    }
    
    

}
