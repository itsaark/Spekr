//
//  UserDetails.swift
//  Spekr
//
//  Created by Arjun Kodur on 2/24/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

//import Parse
//import Foundation
//
//
//class UserDetails: PFObject, PFSubclassing {
//    
//    // 2
//    @NSManaged var totalLikes: NSNumber?
//    @NSManaged var user: PFUser?
//    
//    
//    var usersTotalLikes: Int?
//    //MARK: PFSubclassing Protocol
//    
//    // 3
//    static func parseClassName() -> String {
//        return "UserDetails"
//    }
//    
//    // 4
//    override init () {
//        super.init()
//    }
//    
//    override class func initialize() {
//        var onceToken : dispatch_once_t = 0;
//        dispatch_once(&onceToken) {
//            // inform Parse about this subclass
//            self.registerSubclass()
//        }
//    }
//    
//    func updateTotalLikes(ofUser: PFUser) {
//        
//        user = ofUser
//        
//        totalLikes = userTotalLikes
//        
//        saveInBackgroundWithBlock(nil)
//    }
//    
//    
//}

