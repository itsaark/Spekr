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




class SignInViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        self.view.backgroundColor = UIColor.init(red: 103/255, green: 74/255, blue: 155/255, alpha: 100/100)
        
        navigationController?.navigationBarHidden = true
    }
    
    private func navigateToNamingScreen() {
        performSegueWithIdentifier("JumpToFirstLastNameVC", sender: self)
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
                self.navigateToNamingScreen()
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
            } else {
                print("Uh oh. The user cancelled the Twitter login.")
            }
        }
        
    }
    
    

}
