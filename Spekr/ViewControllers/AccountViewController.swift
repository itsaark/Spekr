//
//  AccountViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/24/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse

class AccountViewController: UIViewController {
    
    
    @IBOutlet weak var displayImage: UIImageView!
    
    @IBOutlet weak var displayName: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        
        //Setting View controller's navigation item properties
        self.navigationController?.navigationItem.title = "Account"
        self.navigationController?.navigationBarHidden = false
        
        
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
