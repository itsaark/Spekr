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
    
    
    
    //User class
    static let ParseUserDetailsClass = "UserDetails"
    static let ParseTotalUserLikes = "totalLikes"
    static let ParseUser = "user"
    
    // Like Relation
    static let ParseLikeClass         = "Likes"
    static let ParseLikeToPost        = "toPost"
    static let ParseLikeFromUser      = "fromUser"
    
    // Post Relation
    static let ParsePostUser          = "username"
    static let ParsePostCreatedAt     = "createdAt"
    static let ParsePostDetailsClass  = "PostDetails"
    static let ParsePostLikesCount    = "likesCount"
    static let ParsePostObjectId      = "objectId"
    
    // Flagged Content Relation
    static let ParseFlaggedContentClass    = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost   = "toPost"
    
    // User Relation
    static let ParseUserUsername      = "username"
    
    // Notification Relation
    static let ParseNotificationToUser         = "toUser"
    static let ParseNotificationCreatedAt      = "createdAt"
    static let ParseNotificationClass          = "Notifications"
    static let ParseNotificationFromUser       = "fromUser"
    static let ParseNotificationToPost         = "toPost"

    

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
    
    static func findTodaysPosts(completionBlock: PFQueryArrayResultBlock) {
        
        let query = PFQuery(className: ParsePostDetailsClass)
        
        let yesterdayDate = NSDate(timeIntervalSinceNow: -86400)
        
        query.whereKey(ParsePostCreatedAt, greaterThan: yesterdayDate)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func requestForWorldFeed(likesMedianValue: Int, completionBlock: PFQueryArrayResultBlock){
        
        let query = PFQuery(className: ParsePostDetailsClass)
        
        let yesterdayDate = NSDate(timeIntervalSinceNow: -86400)
        
        query.whereKey(ParsePostCreatedAt, greaterThan: yesterdayDate)
        
        query.whereKey(ParsePostLikesCount, greaterThan: (likesMedianValue - 1))
        
        query.orderByDescending(ParsePostLikesCount)
        
        //query.limit = 10
        
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
    
    //Send push notifications to near by user when someone posts around them.
    static func pushNotificationToNearByUser(location: PFGeoPoint) {
        
        let query = PFQuery(className: ParsePostDetailsClass)
        query.whereKey("locationCoordinates", nearGeoPoint: location, withinMiles: Double(50))
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if let results = results{
                
                for result in results {
                    
                    let toUser = result.objectForKey("username") as! PFUser
                    
                    let pushQuery = PFInstallation.query()!
                    pushQuery.whereKey("user", equalTo: toUser) //friend is a PFUser object
                    let data = ["alert" : "Someone around you posted on Spker", "badge" : "Increment"]
                    let push = PFPush()
                    push.setQuery(pushQuery)
                    push.setData(data)
                    push.sendPushInBackground()
                }
            }
        }
        
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
    
    static func updateNotificationTab(toUser: PFUser, post: PostDetails){
        
        let query = PFQuery(className: ParseNotificationClass)
        query.whereKey(ParseNotificationToUser, equalTo: toUser)
        query.findObjectsInBackgroundWithBlock { (notifications:[PFObject]?, error: NSError?) -> Void in
        
            if let notifications = notifications{
                
                if notifications == []{
                    
                    let notificationObject = PFObject(className: ParseNotificationClass)
                    notificationObject[ParseNotificationFromUser] = PFUser.currentUser()
                    notificationObject[ParseNotificationToUser] = toUser
                    notificationObject[ParseNotificationToPost] = post
                    
                    notificationObject.saveInBackgroundWithBlock(nil)
                    
                }else{
                    
                    for notification in notifications{
                        
                        if PFUser.currentUser() != notification.objectForKey("fromUser") as? PFUser{
                            
                            let notificationObject = PFObject(className: ParseNotificationClass)
                            notificationObject[ParseNotificationFromUser] = PFUser.currentUser()
                            notificationObject[ParseNotificationToUser] = toUser
                            notificationObject[ParseNotificationToPost] = post
                            
                            notificationObject.saveInBackgroundWithBlock(nil)
                        }
                    }
                    
                }
            }
        }

    }
    
    static func removeNotification(post: PostDetails){
        
        let query = PFQuery(className: ParseNotificationClass)
        query.whereKey(ParseNotificationFromUser, equalTo: PFUser.currentUser()!)
        query.whereKey(ParseNotificationToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if let result = results {
                
                for notificationObject in result {
                    
                    notificationObject.deleteInBackgroundWithBlock(nil)
                }
            }
        }
        
    }
    
    static func loadNotificationsForCurrentUser(completionBlock: PFQueryArrayResultBlock){
        
        let query = PFQuery(className: ParseNotificationClass)
        query.whereKey(ParseNotificationToUser, equalTo: PFUser.currentUser()!)
        query.orderByDescending(ParsePostCreatedAt)
        query.cachePolicy = .CacheThenNetwork
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func loadCurrentUserPosts(completionBlock: PFQueryArrayResultBlock){
        
        let query = PFQuery(className: ParsePostDetailsClass)
        query.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        query.orderByDescending(ParsePostCreatedAt)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    
    
    //Called when "user" deletes post
    static func deleteUserPost(postObjectID: String, completionBlock:PFBooleanResultBlock){
        
        let query = PFQuery(className: ParsePostDetailsClass)
        query.whereKey(ParsePostObjectId, equalTo: postObjectID)
        
        query.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) -> Void in
            
            if let result = result {
                
                for postObject in result{
                    
                    postObject.deleteInBackgroundWithBlock(completionBlock)
                }
            }
        }
    }
    
    static func deleteOldPost(completionBlock: PFQueryArrayResultBlock){
        
        let query = PFQuery(className: ParsePostDetailsClass)
        
        query.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    // MARK: Total likes
    static func totalLikesForUser(user: PFUser, completionBlock: PFQueryArrayResultBlock) {
        
        let query = PFQuery(className: ParseUserDetailsClass)
        query.whereKey(ParseUser, equalTo: user)
        
        query.cachePolicy = .CacheThenNetwork
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func updateTotalLikesOfUser(user: PFUser) {
        
        let query = PFQuery(className: ParseUserDetailsClass)
        query.whereKey("user", equalTo: user)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if let results = results {
                
                for result in results{
                    
                    let objectId = result.objectId
                    print(objectId)
                    let userDetailObject = PFObject(withoutDataWithObjectId: objectId)
                    userDetailObject.incrementKey(ParseTotalUserLikes, byAmount: 1)
                    userDetailObject.saveInBackgroundWithBlock({ (updated: Bool, error: NSError?) -> Void in
                        
                        if error != nil {
                            
                            print("Hey we got an \(error)")
                        }
                    })
                }
            }
        }
        

    
    }
    
    //Creates an user object(for storing likes) when user signs-up.
    static func createUserDetailsInstance(){
        
        let userDetailObject = PFObject(className: ParseUserDetailsClass)
        
        userDetailObject[ParseUser] = PFUser.currentUser()
        userDetailObject[ParseTotalUserLikes] = 0
        
        userDetailObject.saveInBackground()
        
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


