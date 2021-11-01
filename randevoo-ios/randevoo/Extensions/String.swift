//
//  String.swift
//  randevoo
//
//  Created by Lex on 9/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    var iso8601withFractionalSeconds: Date? { return Formatter.iso8601withFractionalSeconds.date(from: self) }
    
    var fetchDateISO: Date? {
        let dateString = self.split(separator: "-")
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        var year = Calendar.current.component(.year, from: date)
        var month = Calendar.current.component(.month, from: date)
        var day = Calendar.current.component(.day, from: date)
        year = Int(dateString[0])!
        month = Int(dateString[1])!
        day = Int(dateString[2])!
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
    
    func replace(string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
    
    func replaceText(current: String, update: String) -> String {
        return self.replace(string: current, replacement: update)
    }
    
    func fetchHour() -> Int {
        return Int(self.split(separator: ":")[0]) ?? 0
    }
    
    func fetchMinute() -> Int {
        return Int(self.split(separator: ":")[1]) ?? 0
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}
