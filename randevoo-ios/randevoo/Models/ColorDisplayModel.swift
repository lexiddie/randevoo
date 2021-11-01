//
//  ColorDisplayModel.swift
//  randevoo
//
//  Created by Xell on 6/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation

class ColorDisplayModel: Codable {
    
    var color: String = ""
    var isAvailable: Bool = false
    
    init(color: String, isAvailable: Bool) {
        self.color = color
        self.isAvailable = isAvailable
    }
}
