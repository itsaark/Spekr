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
import Bond

class DetailCellViewController: UIViewController {
    
    var currentObject : PostDetails?
    
    //Calender Declaration
    let gregorianCal =  NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    
    
    @IBOutlet weak var userDisplayImage: UIImageView!
    
    @IBOutlet weak var userDisplayName: UILabel!
    
    @IBOutlet weak var timeStamp: UILabel!
    
    @IBOutlet weak var postTextView: UITextView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        
        currentObject!.toggleLikePost(PFUser.currentUser()!)
        
        if likeButton.selected == false {
            
            //Like button animation
            likeButton.viewWithTag(0)!.transform = CGAffineTransformMakeScale(0, 0)
            
            UIView.animateWithDuration(0.5,delay: 0.1,usingSpringWithDamping: 0.5,initialSpringVelocity: 10, options: .CurveLinear, animations: {
                    self.likeButton.viewWithTag(0)!.transform = CGAffineTransformIdentity
                },
                completion: nil
            )
            
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
    
    func windowHeight() -> CGFloat {
        
        return UIScreen.mainScreen().bounds.size.height
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

            
            //Setting font size for iPhone5 and below.
            if windowHeight() <= 568{
                
                postTextView.font = UIFont(name: "Helvetica Neue", size: 15)
            }
            
            
            //Changing the height of postTextView based on the content inside the view
            let fixedWidth = postTextView.frame.size.width
            postTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            let newSize = postTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
            var newFrame = postTextView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            postTextView.frame = newFrame

            
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
        
        if currentObject?.likes.value?.count == nil || (currentObject?.likes.value?.count)! == 0 {
            
            likesCountLabel.text = ""
        }
        else{
            
            likesCountLabel.text = "\((currentObject?.likes.value?.count)!)"
        }
        
        if currentObject?.doesUserLikePost(PFUser.currentUser()!) == true {
            
            likeButton.selected = true
        }else {
            likeButton.selected = false
        }

    }
    

}
