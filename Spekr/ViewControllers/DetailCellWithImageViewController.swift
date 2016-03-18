//
//  DetailCellWithImageViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/6/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse
import Foundation
import Bond
import Agrume




class DetailCellWithImageViewController: UIViewController {
    
    var currentObject : PostDetails?
    
    var localLikesCounter: Int?
    

    //Calender Declaration
    let gregorianCal =  NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    
    @IBOutlet weak var progressView: THCircularProgressView!
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var userDisplayImage: UIImageView!
    
    @IBOutlet weak var postTextView: UITextView!
    
    @IBOutlet weak var userDisplayName: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var timeStamp: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        
        currentObject!.toggleLikePost(PFUser.currentUser()!)
        let postedUser = currentObject?.objectForKey("username") as! PFUser
        let postedUserID = postedUser.objectId
        let postObjectID = (currentObject?.objectId)! as String
        let currentUserName = PFUser.currentUser()?.objectForKey("displayName") as! String
        
        
        //Updating likes on UI
        if likeButton.selected == false {
            
            
            //Like button animation
            likeButton.viewWithTag(0)!.transform = CGAffineTransformMakeScale(0, 0)
            
            UIView.animateWithDuration(0.5,delay: 0.1,usingSpringWithDamping: 0.5,initialSpringVelocity: 10, options: .CurveLinear, animations: {
                self.likeButton.viewWithTag(0)!.transform = CGAffineTransformIdentity
                },
                completion: nil
            )
            
            likeButton.selected = true
            localLikesCounter = localLikesCounter! + 1
            likesCountLabel.text = "\(localLikesCounter!)"
            
            //ParseHelper.updateTotalLikesOfUser((currentObject?.objectForKey("username") as? PFUser)!)
            PFCloud.callFunctionInBackground("AddLikeToPost", withParameters: ["postId" : postObjectID])

            PFCloud.callFunctionInBackground("IncrementLike", withParameters: ["user" : postedUser.objectId! as String])
            
            if currentObject?.objectForKey("username") as? PFUser != PFUser.currentUser() {
                //Send a push notification
                ParseHelper.updateNotificationTab(currentObject?.objectForKey("username") as! PFUser, post: currentObject!)

                PFCloud.callFunctionInBackground("sendPushToUser", withParameters: ["user" : currentUserName, "recipientId" : postedUserID!])
            }
        }
        else{
            
            likeButton.selected = false
            PFCloud.callFunctionInBackground("RemoveLikeToPost", withParameters: ["postId" : postObjectID])
            PFCloud.callFunctionInBackground("DecrementLike", withParameters: ["user" : postedUser.objectId! as String])
            
            //Delete notification on Parse backend
            ParseHelper.removeNotification(currentObject!)
            
            if localLikesCounter == 0 {
                
                likesCountLabel.text = ""
                //currentObject!.updateLikesCount(0)
            }
            else if localLikesCounter == 1{
                localLikesCounter = localLikesCounter! - 1
                likesCountLabel.text = ""
                //currentObject!.updateLikesCount(localLikesCounter!)
            }
            else{
                localLikesCounter = localLikesCounter! - 1
                likesCountLabel.text = "\(localLikesCounter!)"
                //currentObject!.updateLikesCount(localLikesCounter!)
            }
        }

    }
    
    //Flag button tapped
    @IBAction func flagButtonTapped(sender: AnyObject) {
        
        
        SweetAlert().showAlert("Are you sure?", subTitle: "Do you want to flag this post as offensive/spam content?", style: AlertStyle.Warning, buttonTitle:"Cancel", buttonColor:UIColor(red: 182, green: 182, blue: 182) , otherButtonTitle:  "Yes, flag it!", otherButtonColor: UIColor(red: 100, green: 240, blue: 150)) { (isOtherButton) -> Void in
            if isOtherButton != true {
                
                ParseHelper.flagPost(PFUser.currentUser()!, post: self.currentObject!)
                
                SweetAlert().showAlert("Flagged!", subTitle: "We'll review it shortly.", style: AlertStyle.Success, buttonTitle: "OK", buttonColor:  UIColor(red: 103, green: 74, blue: 155))
            }

        }
        
    }
    
    
    
    //User's display image/name is tapped. Performing a segue to user profile vc
    func userDisplayTapped(){
        
        if currentObject?.objectForKey("username") as? PFUser != PFUser.currentUser() {
        performSegueWithIdentifier("JumpToUserProfileVC", sender: self)
        //print("imageTapped")
            
        } else{
            
            //User's display image/name is tapped by the user itself. Performing a segue to user account vc
            performSegueWithIdentifier("JumpToAccount", sender: self)
        }
    }

    
    
    func dismissVC() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postImageTapped(){
        
        if let image = self.postImageView.image {
            let agrume = Agrume(image: image)
            agrume.showFrom(self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Check for identifier and jump to user profile VC
        if segue.identifier == "JumpToUserProfileVC" {
            
            let destinationVC = segue.destinationViewController as! UserProfileViewController
            destinationVC.user = currentObject?.objectForKey("username") as? PFUser
        }
    }
    
    //Get device screen height
    func windowHeight() -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("height \(UIScreen.mainScreen().bounds.size.height)")
        
        
        //User display image/name tap gesture recognizer
        let userDisplayImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("userDisplayTapped"))
        self.userDisplayImage.addGestureRecognizer(userDisplayImageTapGestureRecognizer)
        self.userDisplayImage.userInteractionEnabled = true
        
        let userDisplayNameTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("userDisplayTapped"))
        self.userDisplayName.addGestureRecognizer(userDisplayNameTapGestureRecognizer)
        self.userDisplayName.userInteractionEnabled = true
        
        let postImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("postImageTapped"))
        self.postImageView.addGestureRecognizer(postImageTapGestureRecognizer)
        self.postImageView.userInteractionEnabled = true
        
        
        
    }

    
    
    override func viewWillAppear(animated: Bool) {
        
        //setting view controller's title
        self.title = "Post"
        
        
        //Setting likes button state to active/inactive
        if currentObject?.likes.value?.count == nil || (currentObject?.likes.value?.count)! == 0 {
            
            likesCountLabel.text = ""
            localLikesCounter = 0
        }
        else{
            
            likesCountLabel.text = "\((currentObject?.likes.value?.count)!)"
            localLikesCounter = currentObject?.likes.value?.count
        }
        
        if currentObject?.doesUserLikePost(PFUser.currentUser()!) == true {
            
            likeButton.selected = true
        }else {
            likeButton.selected = false
        }

        //Loading and displaying selected post object
        if let object = currentObject {
            
            self.postTextView.text = object["postText"] as! String
            postTextView.textContainerInset = UIEdgeInsetsZero
            postTextView.textContainer.lineFragmentPadding = 0
            
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
            
            //THProgress view while the image is loading
            progressView.radius = progressView.bounds.height/2
            progressView.lineWidth = 15
            progressView.clipsToBounds = false
            progressView.progressColor = UIColor.whiteColor()
            progressView.progressBackgroundColor = UIColor.grayColor()
            progressView.progressBackgroundMode = .Circle
            progressView.backgroundColor = UIColor.clearColor()
            progressView.clockwise = true
            progressView.translatesAutoresizingMaskIntoConstraints = false
            let user = object["username"] as! PFUser
            
            user.fetchIfNeededInBackgroundWithBlock({ (obj: PFObject?, error: NSError?) -> Void in
                
                if obj != nil {
                    
                    let fetchedUser = obj as! PFUser
                    let userName = fetchedUser["displayName"] as! String
                    self.userDisplayName.text = userName
                    
                    //Fetching displayImage
                    let userDisplayImageFile = fetchedUser["displayImage"] as! PFFile
                    userDisplayImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                        
                        if imageData != nil {
                            
                            //Converting displayImage to UIImage
                            let userDisplayImage = UIImage(data: imageData!)
                            self.userDisplayImage.image = userDisplayImage
                            self.userDisplayImage.layer.cornerRadius = 30
                            self.userDisplayImage.clipsToBounds = true
                            
                        }else{
                            
                            self.userDisplayImage.setImageWithString(userName)
                            self.userDisplayImage.layer.cornerRadius = 30
                            self.userDisplayImage.clipsToBounds = true
                        }
                    })
                }
            })
            
            let postImageFile = object["imageFile"] as! PFFile?
            
            NSOperationQueue.mainQueue().cancelAllOperations()
            
            postImageFile?.getDataInBackgroundWithBlock({ (imageData:NSData?, error:NSError?) -> Void in
                
                if imageData != nil {
                    
                    let postDisplayImage = UIImage(data: imageData!)
                    self.postImageView.image = postDisplayImage
                    self.postImageView.clipsToBounds = true
                    
                }
                
                
                }, progressBlock: { (progress: Int32) -> Void in
                    
                    if progress <= 99 {
                        
                        self.progressView.percentage = (CGFloat(progress)/100)
                        
                        //print("CG value: \(CGFloat(progress)/100)")
                        
                        //print(self.progressView.progress)
                        
                    } else {
                        
                        self.progressView.removeFromSuperview()
                    }
                    
            })
            
        }

        
    }

    

}
