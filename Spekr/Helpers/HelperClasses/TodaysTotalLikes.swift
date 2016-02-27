//
//  TodaysTotalLikes.swift
//  Spekr
//
//  Created by Arjun Kodur on 2/26/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse

class TodaysTotalLikes: NSObject {
    
    func getArray() -> [Int]{
        
        var array = [Int]()
        
        ParseHelper.findTodaysPosts { (posts: [PFObject]?, error: NSError?) -> Void in
            
            if posts?.count > 0 {
                
                for post in posts!{
                    
                    if let postLikesCount = post.objectForKey("likesCount") {
                        
                        array.append(postLikesCount as! Int)
                    }
                    
                }
            }else {
                
                array.append(0)
            }
        }
        
        return array
    }
}
