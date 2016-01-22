//
//  UserProfileViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/21/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse

class UserProfileViewController: UIViewController {
    
    var selectedUserObject: PFObject?
    
    @IBOutlet weak var userDisplayImage: UIImageView!
    
    @IBOutlet weak var userDisplayName: UILabel!
    
    
    @IBAction func connectButtonTapped(sender: AnyObject) {
        
        if socialAccountURL != nil {
            
            UIApplication.sharedApplication().openURL(socialAccountURL!)
        }
        
    }
    
    var socialAccountURL: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userObject = selectedUserObject {
            
            let user = userObject["username"] as! PFUser
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
                    let userDisplayImageFile = selectedUser["displayImage"] as! PFFile
                    userDisplayImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                        
                        if error == nil {
                            
                            //Converting displayImage to UIImage
                            let userDisplayImage = UIImage(data: imageData!)
                            self.userDisplayImage.image = userDisplayImage
                            self.userDisplayImage.layer.cornerRadius = 41
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
