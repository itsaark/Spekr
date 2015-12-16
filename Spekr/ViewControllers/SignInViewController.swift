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




class SignInViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        self.view.backgroundColor = UIColor.init(red: 103/255, green: 74/255, blue: 155/255, alpha: 100/100)
        
        navigationController?.navigationBarHidden = true
    }
    
    
    
    private func navigateToNewViewController(Identifier: String) {
        performSegueWithIdentifier(Identifier, sender: self)
    }

    
    //Sign in with Phone Number
    @IBAction func didTapPhoneSignInButton(sender: AnyObject) {
        
        // Create a Digits Instance
        let digits = Digits.sharedInstance()
        
        // Start the Digits authentication flow with the custom appearance.
        digits.authenticateWithCompletion { (session, error) in
            // Inspect session/error objects
            
            if session != nil {
                // We now have access to the user’s verified phone number and to a unique, stable, userID.
                print(session.phoneNumber)
                print(session.userID)
                
                
                // Navigate to the Naming screen.
                self.navigateToNewViewController("JumpFromPhoneSignInToLinkAccount")
            }
        }
        
            
        }
        
    //Sign in with Twitter     
    @IBAction func signInTwitter(sender: AnyObject) {
        
        PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in with Twitter!")
                } else {
                    print("User logged in with Twitter!")
                }
                
                //Performing a segue to Local Feed Screen
                self.navigateToNewViewController("JumpFromSignInToLocalFeed")
                
                
            } else {
                print("Uh oh. The user cancelled the Twitter login.")
            }
        }
        
    }
    
    func returnFBUserDataToParse() {
        
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
                        
                        if(success)
                        {
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
                let myAlert = UIAlertController(title:"Alert", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert);
                
                let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                
                myAlert.addAction(okAction);
                self.presentViewController(myAlert, animated:true, completion:nil);
                
                return
            } else {
                
                if let user = user {
                    if user.isNew {
                        print("User signed up and logged in through Facebook!")
                        
                        self.returnFBUserDataToParse()
                        
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
