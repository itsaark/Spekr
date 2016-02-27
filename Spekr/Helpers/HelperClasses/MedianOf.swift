//
//  MedianOf.swift
//  Spekr
//
//  Created by Arjun Kodur on 2/26/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import Foundation

public class MedianOf: NSObject {
    
    func array(values: [Int]) -> Int {
        let count = Int(values.count)
        if count == 0 { return 0 }
        let sorted = values.sort { $0 < $1 }
        
        if count % 2 == 0 {
            // Even number of items - return the mean of two middle values
            let leftIndex = Int(count / 2 - 1)
            let leftValue = sorted[leftIndex]
            let rightValue = sorted[leftIndex + 1]
            return (leftValue + rightValue) / 2
        } else {
            // Odd number of items - take the middle item.
            return sorted[Int(count / 2)]
        }
    }
}