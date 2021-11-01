//
//  BizType.swift
//  randevoo
//
//  Created by Lex on 7/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class BizType: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    
    
}
