//
//  Notifications.swift
//  Spekr
//
//  Created by Arjun Kodur on 2/8/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import Parse
import Foundation


class Notifications: PFObject, PFSubclassing {
    
    // 2
    @NSManaged var fromUser: PFUser?
    @NSManaged var toUser: PFUser?
    @NSManaged var toPost: PostDetails?

    

    //MARK: PFSubclassing Protocol
    
    // 3
    static func parseClassName() -> String {
        return "Notifications"
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

    
}
