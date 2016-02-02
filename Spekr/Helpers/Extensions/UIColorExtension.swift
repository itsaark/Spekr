//
//  UIColorExtension.swift
//  Spekr
//
//  Created by Arjun Kodur on 2/2/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit

extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}