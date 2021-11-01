//
//  Device.swift
//  randevoo
//
//  Created by Alexander on 25/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class Device: Mappable, Codable {
    
    var id: String! = ""
    var accountId: String! = ""
    var tokens: [Token] = []
    
    init(id: String, accountId: String, tokens: [Token]) {
        self.id = id
        self.accountId = accountId
        self.tokens = tokens
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        accountId <- map["accountId"]
        tokens <- map["tokens"]
    }
}
