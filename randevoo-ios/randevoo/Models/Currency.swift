//
//  Currency.swift
//  randevoo
//
//  Created by Lex on 1/01/2021.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class Currency: Mappable, Codable {
    
    var name: String! = ""
    var code: String! = ""
    var symbol: String! = ""

    init(name: String, code: String, symbol: String) {
        self.name = name
        self.code = code
        self.symbol = symbol
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        name <- map["name"]
        code <- map["code"]
        symbol <- map["symbol"]
    }
}
