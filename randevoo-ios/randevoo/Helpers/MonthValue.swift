//
//  MonthValue.swift
//  randevoo
//
//  Created by Xell on 2/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation

class MonthValue {
    
    func monthValue(month: Int) -> Int {
        if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12 {
            return 31
        } else {
            return 30
        }
            
    }
}
