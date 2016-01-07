//
//  DetailCellViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/6/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse

class DetailCellViewController: UIViewController {
    
    
    var currentObject : PFObject?
    
    @IBOutlet weak var userDisplayImage: UIImageView!
    
    @IBOutlet weak var postTextView: UITextView!
    
    @IBOutlet weak var userDisplayName: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let object = currentObject {
            
            postTextView.text = object["postText"] as! String
            
//            while (postTextView.sizeThatFits(postTextView.frame.size).height > postTextView.frame.size.height) {
//                
//                postTextView.font = postTextView.font?.fontWithSize(postTextView.font!.pointSize-0.5)
//            }
            
            
            
            let sizeThatShouldFitTheContent = postTextView.sizeThatFits(postTextView.frame.size)
            heightConstraint.constant = sizeThatShouldFitTheContent.height
        
            
            let postImageFile = object["imageFile"] as! PFFile?
            
            if postImageFile != nil {
                
                postImageFile?.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                    
                    if imageData != nil {
                        
                        let postDisplayImage = UIImage(data: imageData!)
                        self.postImageView.image = postDisplayImage
                        self.postImageView.clipsToBounds = true
                        
                    }
                })
            }
            
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
