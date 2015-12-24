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
    

    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Do any additional setup after loading the view.
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
        
        self.tabBarController?.navigationItem.title = "Profile"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.navigationController?.navigationBarHidden = false
        self.tabBarController?.navigationItem.hidesBackButton = true

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
