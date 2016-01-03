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
    

    // 2
    static func timelineRequestForCurrentPost(key: String, geoPoint: PFGeoPoint, radius: Double, completionBlock: PFQueryArrayResultBlock) {
        
        let query = PFQuery(className:"PostDetails")
        
        // 5
        
        query.whereKey(key, nearGeoPoint: geoPoint, withinMiles: radius)
        
        query.includeKey("username")
        
        // 3
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    
}


