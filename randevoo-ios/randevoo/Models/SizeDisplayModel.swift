//
//  SizeDisplayModel.swift
//  randevoo
//
//  Created by Xell on 6/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation

class SizeDisplayModel: Codable {
    
    var size: String = ""
    var isAvailable: Bool = false
    
    init(size: String, isAvailable: Bool) {
        self.size = size
        self.isAvailable = isAvailable
    }
}
