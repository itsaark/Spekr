//
//  SettingsViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/24/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse
import DigitsKit
import MessageUI

class SettingsViewController: UIViewController, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    //Initializing mail composer
    let emailComposer = EmailComposer()
    
    //Dismiss mail VC after getting a result.
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    
    }
    //Displaying error message through Alert
    func DisplayAert(title:String, errorMessage:String){
        
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    
    //Customizing the back bar button item
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }

    
    @IBOutlet weak var settingsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //Setting View controller's navigation item properties
        
        self.navigationItem.title = "Settings"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    var settingsList = ["About", "Account", "Nitty Gritty", "Terms of Service", "Send Feedback" , "Log Out"]
    
    // MARK: - UITableViewDataSource
   
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //TODO: AutoLayout constraints for navigation icon not set properly
        //First 3 settings options have a disclosure indicator in the prototype cell
        if indexPath.row < 4 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("CellWithIcon", forIndexPath: indexPath)
        
            cell.textLabel?.text = settingsList[indexPath.row]
            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            
            cell.textLabel?.text = settingsList[indexPath.row]
            cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
            return cell
        }
        
        
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Deselects the seltected cell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //About cell tapped
        if indexPath.row == 0 {
            
            //Segue to about view controller
            self.performSegueWithIdentifier("JumpToAboutVC", sender: self)
            
        }
        //Account cell tapped
        else if indexPath.row == 1 {
            
            //Segue to account view controller
            self.performSegueWithIdentifier("JumpToAccountVC", sender: self)
            
        }
        else if indexPath.row == 2 {
            
            //Segue to Nitty Gritty view controller
            self.performSegueWithIdentifier("JumpToNittyGrittyVC", sender: self)
        }
        else if indexPath.row == 3 {
            
            //Segue to terms of service view controller
            self.performSegueWithIdentifier("JumpToTermsOfService", sender: self)
            
        }
        // Send feedback cell tapped
        else if indexPath.row == 4 {
            
            //Calling Email composer class to send feedback via e-mail
            if emailComposer.canSendMail() {
                let configuredMailComposeViewController = emailComposer.configuredMailComposeViewController("Feedback")
                configuredMailComposeViewController.mailComposeDelegate = self
                self.presentViewController(configuredMailComposeViewController, animated: true, completion: nil)
                
                
            }else{
                
                SweetAlert().showAlert("Could Not Send Email", subTitle: "Your device couldn't send the e-mail. Please check the device configuration and try again later", style: AlertStyle.None)
            }
            
        }
        
        //Log out cell tapped
        else if indexPath.row == 5 {
            
            let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to Log out?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                
                //Log out current user
                
                PFUser.logOutInBackgroundWithBlock({ (error: NSError?) -> Void in
                    
                    if error ==
                        nil {
                     
                        Digits.sharedInstance().logOut()

                    }
                })
                
                //Segue to sing in view controller
                //self.performSegueWithIdentifier("JumpToSignInVC", sender: self)
                //self.dismissViewControllerAnimated(true, completion: nil)
                let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
                let signInViewController = storyboard.instantiateViewControllerWithIdentifier("SignInViewController")
                self.presentViewController(signInViewController, animated: true, completion: nil)
                
                
                
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)

            
        }
    }
    

}
