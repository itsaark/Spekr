//
//  ParseHelper.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/24/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    // Like Relation
    static let ParseLikeClass         = "Likes"
    static let ParseLikeToPost        = "toPost"
    static let ParseLikeFromUser      = "fromUser"
    
    // Post Relation
    static let ParsePostUser          = "username"
    static let ParsePostCreatedAt     = "createdAt"
    static let ParsePostDetailsClass  = "PostDetails"
    static let ParsePostLikesCount    = "likesCount"
    
    // Flagged Content Relation
    static let ParseFlaggedContentClass    = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost   = "toPost"
    
    // User Relation
    static let ParseUserUsername      = "username"

    

    /// MARK: Timeline request
    static func timelineRequestForCurrentPost(key: String, geoPoint: PFGeoPoint, radius: Double, completionBlock: PFQueryArrayResultBlock) {
        
        let query = PFQuery(className: ParsePostDetailsClass)
        
        // 5
        
        query.whereKey(key, nearGeoPoint: geoPoint, withinMiles: radius)
        
        query.includeKey(ParsePostUser)
        
        query.orderByDescending(ParsePostCreatedAt)
        
        query.cachePolicy = .NetworkElseCache
        
        // 3
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func requestForWorldFeed(completionBlock: PFQueryArrayResultBlock){
        
        let query = PFQuery(className: ParsePostDetailsClass)
        
        query.whereKey(ParsePostLikesCount, greaterThan: 1)
        
        query.orderByDescending(ParsePostLikesCount)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    
    
    // MARK: Likes
    static func likePost(user: PFUser, post: PostDetails) {
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(nil)
    }
    
    static func unlikePost(user: PFUser, post: PostDetails) {
        // 1
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if let result = results {
                
                for likes in result {
                    
                    likes.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    
    static func likesForPost(post: PostDetails, completionBlock: PFQueryArrayResultBlock) {
        
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        // 2
        query.includeKey(ParseLikeFromUser)
        
        query.cachePolicy = .CacheThenNetwork
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    // MARK: Push notifications
    static func sendPushNotification(toUser: PFUser, toPostID: String){
        
        let pushQuery = PFInstallation.query()!
        pushQuery.whereKey("user", equalTo: toUser) //friend is a PFUser object
        
        let currentUserName = PFUser.currentUser()?.objectForKey("displayName") as! String
        
        let data = ["alert" : "\(currentUserName) liked your post", "badge" : "Increment", "currentUser": "\(PFUser.currentUser())", "toPostID":"\(toPostID)"]
        let push = PFPush()
        push.setQuery(pushQuery)
        push.setData(data)
        push.sendPushInBackground()
    }
    
    // MARK: Flagged content
    
    static func flagPost(user: PFUser, post: PostDetails) {
        let flagObject = PFObject(className: ParseFlaggedContentClass)
        flagObject[ParseFlaggedContentFromUser] = user
        flagObject[ParseFlaggedContentToPost] = post
        
        flagObject.saveInBackgroundWithBlock(nil)
    }
    
    static func unflagPost(user: PFUser, post: PostDetails) {
        // 1
        let query = PFQuery(className: ParseFlaggedContentClass)
        query.whereKey(ParseFlaggedContentFromUser, equalTo: user)
        query.whereKey(ParseFlaggedContentToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if let result = results {
                
                for flags in result {
                    
                    flags.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }

 
}

extension PFObject {
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        } else {
            return super.isEqual(object)
        }
    }
    
}


