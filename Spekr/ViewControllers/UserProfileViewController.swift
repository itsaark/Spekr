//
//  UserProfileViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/21/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse
import SDWebImage

class UserProfileViewController: UIViewController {
    
    var user: PFUser?
    var selectedUserObject: PFObject?
    let alertView = SweetAlert()
    
    @IBOutlet weak var userDisplayImage: UIImageView!
    
    @IBOutlet weak var userDisplayName: UILabel!
    
    @IBAction func connectButtonTapped(sender: AnyObject) {
        
        if socialAccountURL != nil {
            
            UIApplication.sharedApplication().openURL(socialAccountURL!)
        }
        
    }
    
    var socialAccountURL: NSURL?
    
    func flagUser(){
        
        let userId = user?.objectId
        let fromUserId = PFUser.currentUser()?.objectId
        
        alertView.showAlert("Are you sure?", subTitle: "Do you want to report this user?", style: AlertStyle.Warning, buttonTitle:"Cancel", buttonColor:UIColor(red: 182, green: 182, blue: 182) , otherButtonTitle:  "Yes", otherButtonColor: UIColor(red: 100, green: 240, blue: 150)) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
               
            }
            else {
                
                PFCloud.callFunctionInBackground("flagUser", withParameters: ["user" : userId!, "fromUser": fromUserId!])
                SweetAlert().showAlert("Flagged!", subTitle: "User has been reported.", style: AlertStyle.Success, buttonTitle: "OK", buttonColor:  UIColor(red: 103, green: 74, blue: 155))
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.userDisplayImage.layer.cornerRadius = 41
        self.userDisplayImage.clipsToBounds = true
        
        if let user = user {
            
            user.fetchIfNeededInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
                
                if object != nil {
                    
                    let selectedUser = object as! PFUser
                    let userName = selectedUser["displayName"] as! String
                    if let socialAccountLinkString = selectedUser["link"] as? String {
                        let url = NSURL(string: socialAccountLinkString)
                        self.socialAccountURL = url
                    }
                    
                    self.userDisplayName.text = userName
                    
                    //Fetching displayImage
                    if let userDisplayImageFile = selectedUser["displayImage"] as! PFFile?{
                        
                        let imageUrl = NSURL(string: userDisplayImageFile.url!)
                        self.userDisplayImage.sd_setImageWithURL(imageUrl)
                        self.userDisplayImage.layer.cornerRadius = 41
                        self.userDisplayImage.clipsToBounds = true
                        
                    }else{
                        
                        self.userDisplayImage.setImageWithString(userName)
                        self.userDisplayImage.layer.cornerRadius = 41
                        self.userDisplayImage.clipsToBounds = true
                    }
                }
            })
            
        }
        
        //Setting right bar button item
        let flagButtonImage = UIImage(named: "FlagIcon")
        
        let flagButton = UIBarButtonItem(image: flagButtonImage, style: .Plain, target: self, action: "flagUser")
        flagButton.tintColor = UIColor(red: 251, green: 209, blue: 75)
        
        self.navigationItem.rightBarButtonItem = flagButton

    }

    
}
