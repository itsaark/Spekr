//
//  AccountViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/24/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse
import Social

class AccountViewController: UIViewController, UITableViewDelegate {
    
    var activityViewController: UIActivityViewController!
    
    var postDetails: [PostDetails] = []
    
    //Calender Declaration
    let gregorianCal =  NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

    
    @IBOutlet weak var displayImage: UIImageView!
    
    @IBOutlet weak var displayName: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func inviteButtonTapped(sender: UIButton){
        
        activityViewController = UIActivityViewController(activityItems: ["Explore beyond your social network with Spekr. Check it out here http://spekrapp.com"], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,
            UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop]
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //Setting View controller's navigation item properties
        self.navigationController?.navigationItem.title = "Account"
        self.navigationController?.navigationBarHidden = false
        
        ParseHelper.loadCurrentUserPosts { (result: [PFObject]?, error: NSError?) -> Void in
            
            self.postDetails = result as? [PostDetails] ?? []
            print(self.postDetails)
            self.tableView.reloadData()
        }
        
        super.viewDidAppear(animated)
        
        //Displaying current user name
        if let parseDisplayName = PFUser.currentUser()!["displayName"] as? String {
            self.displayName.text = parseDisplayName
        }
        //Displaying current user displayImage
        if let parseDisplayImage = PFUser.currentUser()!["displayImage"] as? PFFile {
            
            parseDisplayImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                
                if imageData != nil {
                    
                    let image = UIImage(data: imageData!)
                    
                    self.displayImage.image = image
                    self.displayImage.layer.cornerRadius = 41
                    self.displayImage.clipsToBounds = true
                    
                    
                }else {
                    //Setting default text picture when imageData is not available
                    self.displayImage.setImageWithString(self.displayName.text)
                    self.displayImage.layer.cornerRadius = 41
                    self.displayImage.clipsToBounds = true
                }
            })
        }

   
    }

    override func viewDidLoad() {
        super.viewDidLoad()        
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableViewAutomaticDimension

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension AccountViewController: UITableViewDataSource {
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postDetails.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            print("Here is the iD: \(postDetails[indexPath.row].objectId)")
            let postObjectId = postDetails[indexPath.row].objectId
            
            ParseHelper.deleteUserPost(postDetails[indexPath.row].objectId! as String, completionBlock: { (result:Bool, error:NSError?) -> Void in
                
                if result {
                    
                    PFCloud.callFunctionInBackground("deletePostsAssociatedLikes", withParameters: ["postId" : postObjectId!])
                    PFCloud.callFunctionInBackground("deletePostsAssociatedNotifications", withParameters: ["postId" : postObjectId!])
                }
            })
            
            self.postDetails.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UserPostCell") as! UserPostTableViewCell
        
        cell.postTextLabel.text = postDetails[indexPath.row].postText
        
        if postDetails[indexPath.row].likesCount != nil {
            
            let likesCount = postDetails[indexPath.row].likesCount
            
            cell.likesCountLabel.text = likesCount?.stringValue
        }
        
        let createdAtDate = postDetails[indexPath.row].createdAt
        
        //Getting date components from NSDate
        let dateComponents = gregorianCal.components([NSCalendarUnit.Era, NSCalendarUnit.Year, NSCalendarUnit.Month,NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: createdAtDate!)
        
        let postedDate = gregorianCal.dateWithEra(dateComponents.era, year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: dateComponents.hour, minute: dateComponents.minute, second: dateComponents.second, nanosecond: dateComponents.nanosecond)
        
        //calling relative time property from Date Format
        let postedRelativeTime = postedDate?.relativeTime
        
        cell.timeStamp.text = postedRelativeTime
        
        return cell
        
    }
}
