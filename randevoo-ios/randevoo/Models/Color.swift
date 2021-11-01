//
//  Color.swift
//  randevoo
//
//  Created by Lex on 18/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class Color: Mappable, Codable {
    
    var name: String! = ""
    var code: String! = ""

    init(name: String, code: String) {
        self.name = name
        self.code = code
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        name <- map["name"]
        code <- map["code"]
    }
}

