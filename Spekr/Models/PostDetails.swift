//
//  PostDetails.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/1/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import Parse
import Foundation

class PostDetails: PFObject, PFSubclassing {
    
    // 2
    @NSManaged var imageFile: PFFile?
    @NSManaged var username: PFUser?
    @NSManaged var postText: String?
    @NSManaged var locationCoordinates: PFGeoPoint?
    
    var image: UIImage?
    var photoUploadTask: UIBackgroundTaskIdentifier?
    //MARK: PFSubclassing Protocol
    
    // 3
    static func parseClassName() -> String {
        return "PostDetails"
    }
    
    // 4
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    func uploadPost() {
        if let image = image {
            // 1
            let imageData = UIImageJPEGRepresentation(image, 0.8)!
            let imageFile = PFFile(data: imageData)
            
            //Uploading image in background
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            imageFile?.saveInBackgroundWithBlock({ (Success: Bool, error: NSError?) -> Void in
                
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            })
            
            // 2
            self.imageFile = imageFile
            
        }
        username = PFUser.currentUser()
        saveInBackgroundWithBlock(nil)
    }

}
