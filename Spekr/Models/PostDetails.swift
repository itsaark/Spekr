//
//  PostDetails.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/1/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import Parse
import Foundation
import Bond

class PostDetails: PFObject, PFSubclassing {
    
    // 2
    @NSManaged var imageFile: PFFile?
    @NSManaged var username: PFUser?
    @NSManaged var postText: String?
    @NSManaged var locationCoordinates: PFGeoPoint?
    @NSManaged var likesCount: NSNumber?
    
    var image: Observable<UIImage?> = Observable(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    var likes: Observable<[PFUser]?> = Observable(nil)
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
    
    func uploadPost(completionBlock: PFBooleanResultBlock) {
        
        ParseHelper.deleteOldPost { (posts: [PFObject]?, error: NSError?) -> Void in
        
            if posts?.count > 0 {
                
                if let posts = posts {
                    
                    for post in posts {
                        
                        let postObjectId = post.objectId
                        PFCloud.callFunctionInBackground("deletePostsAssociatedLikes", withParameters: ["postId" : postObjectId!])
                        PFCloud.callFunctionInBackground("deletePostsAssociatedNotifications", withParameters: ["postId" : postObjectId!])
                        post.deleteInBackgroundWithBlock({ (deleted: Bool, error: NSError?) -> Void in
                            
                            if let image = self.image.value {
                                // 1
                                let imageData = UIImageJPEGRepresentation(image, 0.8)!
                                let imageFile = PFFile(data: imageData)
                                
                                //Uploading image in background
                                self.photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                                    UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
                                }
                                
                                imageFile?.saveInBackgroundWithBlock({ (Success: Bool, error: NSError?) -> Void in
                                    
                                    UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
                                })
                                
                                // 2
                                self.imageFile = imageFile
                                
                            }
                            self.username = PFUser.currentUser()
                            self.likesCount = 0
                            self.saveInBackgroundWithBlock(completionBlock)
                        })
                    }
                }
            }else {
                
                if let image = self.image.value {
                    // 1
                    let imageData = UIImageJPEGRepresentation(image, 0.8)!
                    let imageFile = PFFile(data: imageData)
                    
                    //Uploading image in background
                    self.photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                        UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
                    }
                    
                    imageFile?.saveInBackgroundWithBlock({ (Success: Bool, error: NSError?) -> Void in
                        
                        UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
                    })
                    
                    // 2
                    self.imageFile = imageFile
                    
                }
                self.username = PFUser.currentUser()
                self.likesCount = 0
                self.saveInBackgroundWithBlock(completionBlock)
            }
        }
    }
    
    func downloadImage() {
        // if image is not downloaded yet, get it
        // 1
        if (image.value == nil) {
            // 2
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    // 3
                    self.image.value = image
                }
            }
        }
    }
    
    func fetchLikes() {
        // 1
        if (likes.value != nil) {
            return
        }
        
        // 2
        ParseHelper.likesForPost(self, completionBlock: { (var likes: [PFObject]?, error: NSError?) -> Void in
            // 3
            likes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            // 4
            self.likes.value = likes?.map { like in
                
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    
    func doesUserLikePost(user: PFUser) -> Bool {
        
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        
        if (doesUserLikePost(user)) {
            // if image is liked, unlike it now
            // 1
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this image is not liked yet, like it now
            // 2
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
    func updateLikesCount(count: NSNumber) {
        
        self.likesCount = count
        
        self.saveInBackground()
    }

}
