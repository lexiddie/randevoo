//
//  ISO8601DateFormatter.swift
//  randevoo
//
//  Created by Alexander on 25/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

extension ISO8601DateFormatter {
    
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}
