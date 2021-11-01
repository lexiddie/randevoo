//
//  Date.swift
//  randevoo
//
//  Created by Lex on 1/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

extension Date {
    
    var iso8601withFractionalSeconds: String {
        return Formatter.iso8601withFractionalSeconds.string(from: self)
    }
    
    var millisecondsSince1970: Double {
        return Double(self.timeIntervalSince1970 * 1000)
    }
    
    init(milliseconds: Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
}
