//
//  DetailCellViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/21/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit
import Foundation
import Parse

class DetailCellViewController: UIViewController {
    
    
    var currentObject : PFObject?
    
    //Calender Declaration
    let gregorianCal =  NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    
    
    @IBOutlet weak var userDisplayImage: UIImageView!
    
    @IBOutlet weak var userDisplayName: UILabel!
    
    @IBOutlet weak var timeStamp: UILabel!
    
    @IBOutlet weak var postTextView: UITextView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        
        if likeButton.selected == false {
            
            likeButton.selected = true
        }
        else{
            
            likeButton.selected = false
        }
    }
    
    
    //user's display image is tapped. Performing a segue to user profile vc
    func userDisplayImageTapped(){
        
        performSegueWithIdentifier("JumpToUserProfileVC", sender: self)
        print("imageTapped")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "JumpToUserProfileVC" {
            
            let destinationVC = segue.destinationViewController as! UserProfileViewController
            destinationVC.selectedUserObject = currentObject
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDisplayImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("userDisplayImageTapped"))
        self.userDisplayImage.addGestureRecognizer(userDisplayImageTapGestureRecognizer)
        self.userDisplayImage.userInteractionEnabled = true

        if let object = currentObject {
            
            self.postTextView.text = object["postText"] as! String
            self.postTextView.textContainerInset = UIEdgeInsetsZero
            self.postTextView.textContainer.lineFragmentPadding = 0
            
            
            //Changing the height of postTextView based on the content inside the view
            let sizeThatShouldFitTheContent = postTextView.sizeThatFits(postTextView.frame.size)
            heightConstraint.constant = sizeThatShouldFitTheContent.height
            
            let createdAtDate = object.createdAt
            
            //Getting date components from NSDate
            let dateComponents = gregorianCal.components([NSCalendarUnit.Era, NSCalendarUnit.Year, NSCalendarUnit.Month,NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond], fromDate: createdAtDate!)
            
            let postedDate = gregorianCal.dateWithEra(dateComponents.era, year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: dateComponents.hour, minute: dateComponents.minute, second: dateComponents.second, nanosecond: dateComponents.nanosecond)
            
            //calling relative time property from Date Format
            let postedRelativeTime = postedDate?.relativeTime
            
            timeStamp.text = postedRelativeTime
            
            
            let user = object["username"] as! PFUser
            
            user.fetchIfNeededInBackgroundWithBlock({ (obj: PFObject?, error: NSError?) -> Void in
                
                if obj != nil {
                    
                    let fetchedUser = obj as! PFUser
                    let userName = fetchedUser["displayName"] as! String
                    self.userDisplayName.text = userName
                    
                    //Fetching displayImage
                    let userDisplayImageFile = fetchedUser["displayImage"] as! PFFile
                    userDisplayImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                        
                        if error == nil {
                            
                            //Converting displayImage to UIImage
                            let userDisplayImage = UIImage(data: imageData!)
                            self.userDisplayImage.image = userDisplayImage
                            self.userDisplayImage.layer.cornerRadius = 30
                            self.userDisplayImage.clipsToBounds = true
                        }
                    })
                }
            })
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //setting view controller's title
        self.title = "Post"
        
        //Makes toolbar appear
        self.navigationController?.toolbarHidden = false
    }
    

}
