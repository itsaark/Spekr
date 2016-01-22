//
//  ProfileViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/24/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var displayImage: UIImageView!
    
    @IBOutlet weak var displayName: UILabel!
    
    @IBAction func connectButtonTapped(sender: AnyObject) {
        
        if PFUser.currentUser()!.isLinkedWithAuthType("twitter"){
            
            print("linked to twitter")

            
            if let userProfileLink = PFUser.currentUser()!["link"] as? String {
                
                if let url = NSURL(string: userProfileLink) {
                    
                    UIApplication.sharedApplication().openURL(url)
                }
            }

            
        }else if PFUser.currentUser()!.isLinkedWithAuthType("facebook"){
            
            print("linked to fb")
            
            if let userProfileLink = PFUser.currentUser()!["link"] as? String {
                
                if let url = NSURL(string: userProfileLink) {
                    
                    print(url)
                    
                    UIApplication.sharedApplication().openURL(url)
                    
                }
            }
        }
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        //Displaying current user name
        if let parseDisplayName = PFUser.currentUser()!["displayName"] as? String {
            self.displayName.text = parseDisplayName
        }
        //Displaying current user displayImage
        if let parseDisplayImage = PFUser.currentUser()!["displayImage"] as? PFFile {
            
            parseDisplayImage.getDataInBackgroundWithBlock({ (imageDate: NSData?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    let image = UIImage(data: imageDate!)
                    
                    self.displayImage.image = image
                    self.displayImage.layer.cornerRadius = 41
                    self.displayImage.clipsToBounds = true
                    
                    
                }
            })
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //Setting View controller's navigation item properties
        self.tabBarController?.navigationItem.title = "Profile"
        self.tabBarController?.navigationController?.navigationBarHidden = false
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
