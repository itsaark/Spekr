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

class SettingsViewController: UIViewController, UITableViewDelegate {
    
    
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
        
        self.tabBarController?.navigationItem.title = "Settings"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    var settingsList = ["About", "Privacy", "Invite Friends", "Support", "Send Feedback", "Log Out"]
    
    // MARK: - UITableViewDataSource
   
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //TODO: AutoLayout constraints for navigation icon not set properly
        //First 3 settings options have a navigation icon in the prototype cell
        if indexPath.row < 3 {
            
        let cell = tableView.dequeueReusableCellWithIdentifier("CellWithIcon", forIndexPath: indexPath)
        
        cell.textLabel?.text = settingsList[indexPath.row]
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            
            cell.textLabel?.text = settingsList[indexPath.row]
            
            return cell
        }
        
        
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if indexPath.row == 0 {
            
        }
        else if indexPath.row == 1 {
            
        }
        else if indexPath.row == 2 {
            
        }
        else if indexPath.row == 3 {
            
        }
        else if indexPath.row == 4 {
            
        }
        
        //Log out cell tapped
        else if indexPath.row == 5 {
            
            let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to Log out?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                
                //Log out current user
                Digits.sharedInstance().logOut()
                PFUser.logOut()
    
                //Segue to sing in view controller
                self.performSegueWithIdentifier("JumpToSignInVC", sender: self)
                
                
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)

            
        }
    }
    
    
   

}
