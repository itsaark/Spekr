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
    
    @IBOutlet weak var userDisplayImage: UIImageView!
    
    @IBOutlet weak var userDisplayName: UILabel!
    
    @IBOutlet weak var heartIcon: UIImageView!
    
    @IBOutlet weak var likesLabel: UILabel!
    
    
    @IBAction func connectButtonTapped(sender: AnyObject) {
        
        if socialAccountURL != nil {
            
            UIApplication.sharedApplication().openURL(socialAccountURL!)
        }
        
    }
    
    var socialAccountURL: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            ParseHelper.totalLikesForUser(user) { (results: [PFObject]?, error: NSError?) -> Void in
                
                if let results = results {
                    
                    for result in results{
                        
                        if let likesCount = result.objectForKey("totalLikes") as! Int? {
                            
                            self.likesLabel.text = String(likesCount)
                            
                        }else {
                            
                            self.likesLabel.text = ""
                            self.heartIcon.hidden = true
                        }
                    }
                    
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.userDisplayImage.layer.cornerRadius = 41
        self.userDisplayImage.clipsToBounds = true
        

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
