//
//  DateFormat.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/11/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//


import Foundation

extension NSDate {
    
    func yearsFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: NSCalendarOptions()).year
    }
    func monthsFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: NSCalendarOptions()).month
    }
    func weeksFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: NSCalendarOptions()).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: NSCalendarOptions()).day
    }
    func hoursFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: NSCalendarOptions()).hour
    }
    func minutesFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: NSCalendarOptions()).minute
    }
    func secondsFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: NSCalendarOptions()).second
    }
    var relativeTime: String {
        let now = NSDate()
        if now.yearsFrom(self)   > 0 {
            return now.yearsFrom(self).description  + "yr"  + { return now.yearsFrom(self)   > 1 ? "" : "" }() + " ago"
        }
        if now.monthsFrom(self)  > 0 {
            return now.monthsFrom(self).description + "mth" + { return now.monthsFrom(self)  > 1 ? "" : "" }() + " ago"
        }
        if now.weeksFrom(self)   > 0 {
            return now.weeksFrom(self).description  + "w"  + { return now.weeksFrom(self)   > 1 ? "" : "" }() + " ago"
        }
        if now.daysFrom(self)    > 0 {
            if now.daysFrom(self) == 1 { return "1d ago" }
            return now.daysFrom(self).description + "d ago"
        }
        if now.hoursFrom(self)   > 0 {
            return "\(now.hoursFrom(self))hr"     + { return now.hoursFrom(self)   > 1 ? "" : "" }() + " ago"
        }
        if now.minutesFrom(self) > 0 {
            return "\(now.minutesFrom(self))min" + { return now.minutesFrom(self) > 1 ? "" : "" }() + " ago"
        }
        if now.secondsFrom(self) > 0 {
            if now.secondsFrom(self) < 15 { return "Just now"  }
            return "\(now.secondsFrom(self))sec" + { return now.secondsFrom(self) > 1 ? "" : "" }() + " ago"
        }
        return ""
    }
}