//
//  Region.swift
//  randevoo
//
//  Created by Lex on 1/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class Region: Mappable, Codable {
    
    var name: String! = ""
    var thai: String! = ""

    init(name: String, thai: String) {
        self.name = name
        self.thai = thai
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        name <- map["name"]
        thai <- map["thai"]
    }
    
    
}
