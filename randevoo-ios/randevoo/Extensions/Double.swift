//
//  Double.swift
//  randevoo
//
//  Created by Lex on 17/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit

extension Double {
    
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
    
