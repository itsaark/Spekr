//
//  NotificationsViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/24/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse

class NotificationsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var count = 0 //temporary notifications count

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //Setting View controller's navigation item properties
        self.tabBarController?.navigationItem.title = "Notifications"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        //Setting badge value to Nil
        (tabBarController!.tabBar.items![2]).badgeValue = nil
        

    }
    

}

extension NotificationsViewController: UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //Setting placeholder image
        if count == 0{
            let image = UIImage(named: "NotificationPlaceholder")
            
            let imageView = UIImageView(image: image)
            //imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
            imageView.frame = self.tableView.frame
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            
            self.tableView.backgroundView = imageView
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
            
        } else {
            //Hiding the background before the view loads
            self.tableView.backgroundView?.hidden = true
            return count
            
        }
        
        
    }
    
    //Footer color
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        view.tintColor = UIColor(red: 238, green: 238, blue: 242)
    }
    
    //Footer height
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 10
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell")! as UITableViewCell
        
        return cell
    }
    
    
}
