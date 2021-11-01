//
//  HandleDateTime.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit

class TimestampHelper {
    
    func getDateMillis() -> Double {
        let result = NSDate().timeIntervalSince1970
        return Double(result * 1000)
    }
    
    // 2/13/21, 10:35 PM
    func toDateTimeShort(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // Feb 13, 2021 at 10:35:31 PM
    func toDateTimeMedium(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // February 13, 2021 at 10:35:31 PM GMT+7
    func toDateTimeLong(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // Saturday, February 13, 2021 at 10:35:31 PM Indochina Time
    func toDateTimeFull(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // 13/02/21
    func toDateShort(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // Feb 13, 2021
    func toDateMedium(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // Sat, Feb 13
    func toDateLong(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // Monday 08 March 2021
    func toDateStandard(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd MMMM yyyy"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // Saturday, February 13, 2021
    func toDateFull(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd, yyyy"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // 22:35
    func toTimeShort(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // 22:35:31
    func toTimeMedium(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // 10:35:31 PM
    func toTimeLong(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // 10:35:31 PM Indochina Time
    func toTimeFull(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a zzzz"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // 13/02/21, 22:35
    func toShort(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy, HH:mm"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // Feb 13, 2021, 22:35
    func toMedium(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy, HH:mm"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    // 22:35-23:08
    func toTimeRange(firstDate: Date, secondDate: Date) -> String {
        let first = toTimeShort(date: firstDate)
        let second = toTimeShort(date: secondDate)
        return "\(first)-\(second)"
    }
    
    // February 2021
    func toJoinedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
    //13-02-2021
    func DateWithHyphen(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.string(from: date as Date)
    }
    
}


