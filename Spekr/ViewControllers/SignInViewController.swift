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
    
    override func viewDidLoad() {
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        navigationController?.navigationBarHidden = true

    }
    
    //Displaying error message through Alert
    let alert = SweetAlert()
    
    //Funtion for seguing from one view controller to other
    private func navigateToNewViewController(Identifier: String) {
        performSegueWithIdentifier(Identifier, sender: self)
    }


    
    //Sign in with Phone Number button tapped
    @IBAction func didTapPhoneSignInButton(sender: AnyObject) {
        
        PFUser.loginWithDigitsInBackground { (user: PFUser?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let user = user {
                    
                    if user.isLinkedWithAuthType("facebook") || user.isLinkedWithAuthType("twitter") {
                    
                    //TODO: Change the string in this func to "JumpFromSignInToLocalFeed" when isNew property is added.

                        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                        appDelegate.setMainTabBarControllerAsRoot()
                            
                        }

                    
                    }else {
                    //TODO: Change the string in this func to "JumpFromSignInToLocalFeed" when isNew property is added.
                        self.navigateToNewViewController("JumpFromPhoneSignInToLinkAccount")
                    
                    }
                }

            
            } else {
                
                if let error = error {
                    
                    if let errorString = error.userInfo["error"] as? NSString {
                        
                        self.alert.showAlert("Error", subTitle: errorString as String, style: AlertStyle.Error, buttonTitle: "OK")
                    }
                    
                }
            }

        }
            
    }
    

}
