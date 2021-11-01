//
//  PhoneNumber.swift
//  randevoo
//
//  Created by Lex on 21/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class PhoneNumber: Mappable, Codable {
    
    var id: String! = ""
    var userId: String! = ""
    var number: String! = ""
    var country: String! = ""
    var verified: Bool! = false
    var createdAt: String! = ""
    var isCurrent: Bool! = false

    init(id: String, userId: String, number: String, country: String, verified: Bool, createdAt: String, isCurrent: Bool) {
        self.id = id
        self.userId = userId
        self.number = number
        self.country = country
        self.verified = verified
        self.createdAt = createdAt
        self.isCurrent = isCurrent
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        number <- map["number"]
        country <- map["country"]
        verified <- map["verified"]
        createdAt <- map["createdAt"]
        isCurrent <- map["isCurrent"]
    }
}
