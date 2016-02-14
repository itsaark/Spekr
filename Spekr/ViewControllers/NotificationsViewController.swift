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
    
    var notifications: [Notifications] = []
    
    //Calender Declaration
    let gregorianCal =  NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

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
        
        ParseHelper.loadNotificationsForCurrentUser { (objects: [PFObject]?, error: NSError?) -> Void in
            
            self.notifications = objects as? [Notifications] ?? []
            print(self.notifications)
            self.tableView.reloadData()
        }
        
        //Setting badge value to Nil
        (tabBarController!.tabBar.items![2]).badgeValue = nil
        

    }
    

}

extension NotificationsViewController: UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //Setting placeholder image
        if notifications.count == 0{
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
            return notifications.count
            
        }
        
        
    }
    
    //Header
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if section == 0 {
            
            view.tintColor = UIColor(red: 238, green: 238, blue: 242)
            
        }
    }
    
    //Header height
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0{
            
            return 10
        }else{
            
            return 0
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell") as! NotificationTableViewCell
        
        let createdAtDate = notifications[indexPath.section].createdAt
        
        //Getting date components from NSDate
        let dateComponents = gregorianCal.components([NSCalendarUnit.Era, NSCalendarUnit.Year, NSCalendarUnit.Month,NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: createdAtDate!)
        
        let notificationCreatedDate = gregorianCal.dateWithEra(dateComponents.era, year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: dateComponents.hour, minute: dateComponents.minute, second: dateComponents.second, nanosecond: dateComponents.nanosecond)
        
        //calling relative time property from Date Format
        let notificationRelativeTime = notificationCreatedDate?.relativeTime
        
        cell.timeStamp.text = notificationRelativeTime
        
        let notificationFromUser = notifications[indexPath.section].objectForKey("fromUser") as! PFUser
        
        //Fetching displayName & displayImage of the user
        notificationFromUser.fetchIfNeededInBackgroundWithBlock { (obj: PFObject?, error: NSError?) -> Void in
            
            if obj != nil {
                
                let fetchedUser = obj as! PFUser
                let username = fetchedUser["displayName"] as! String
                cell.fromUserDisplayName.text = username
                
                //Fetching displayImage
                let userDisplayImageFile = fetchedUser["displayImage"] as! PFFile
                userDisplayImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                    
                    if error == nil {
                        
                        //Converting displayImage to UIImage
                        let userDisplayImage = UIImage(data: imageData!)
                        cell.fromUserDisplayImage.image = userDisplayImage
                        cell.fromUserDisplayImage.layer.cornerRadius = 15
                        cell.fromUserDisplayImage.clipsToBounds = true
                    }
                })
            }
        }

        
        return cell
    }
    
    
}
