//
//  LaunchViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 2/17/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse
import Fabric
import DigitsKit
import TwitterKit
import FBSDKCoreKit
import ParseTwitterUtils
import ParseFacebookUtilsV4
import Spring


class LaunchViewController: UIViewController {
    
    @IBOutlet weak var spekrLogo: SpringImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Logo animation
        spekrLogo.animateNext { () -> () in
            
            //Checking for current user
            if PFUser.currentUser() == nil {
                
                UIView.animateWithDuration(Double(1.5), delay: Double(0.0), options: [UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse], animations: { () -> Void in
                    }) { (bool: Bool) -> Void in
                        
                        if bool {
                            
                            self.performSegueWithIdentifier("JumpToSignInVC", sender: self)
                        }
                }
                
             }else {
                
                if let user = PFUser.currentUser() {
                    
                    if user.isLinkedWithAuthType("facebook") || user.isLinkedWithAuthType("twitter") {
                        
                        //print("this is getting called")
                        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                            appDelegate.setMainTabBarControllerAsRoot()
                        }
                        
                        
                    }else{

                        self.performSegueWithIdentifier("JumpToSignInVC", sender: self)
                    }
                    
                }
                
            }
         
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        navigationController?.navigationBarHidden = true
        

    }


}
