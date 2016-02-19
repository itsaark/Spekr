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


class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        navigationController?.navigationBarHidden = true

    }
    
    override func viewDidAppear(animated: Bool) {
        
        //PFUser.logOut()
        //Digits.sharedInstance().logOut()
        
        print("Fbskd not called \(FBSDKAccessToken.currentAccessToken())")
        
        if PFUser.currentUser()
            == nil {
                
                //            let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
                //            let signInViewController = storyboard.instantiateViewControllerWithIdentifier("SignInViewController")
                
                self.performSegueWithIdentifier("JumpToSignInVC", sender: self)
                //            let storyboardtwo = UIStoryboard(name: "Main", bundle: nil)
                //            let tabBarController = storyboardtwo.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                
        }else {
            
            print("currentuser: \(PFUser.currentUser())")
            
            PFUser.becomeInBackground(FBSDKAccessToken.currentAccessToken().tokenString)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
            self.presentViewController(tabBarController, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
