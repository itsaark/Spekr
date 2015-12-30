//
//  SettingsViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/24/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit

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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
