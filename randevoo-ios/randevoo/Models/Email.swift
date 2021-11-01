//
//  Email.swift
//  randevoo
//
//  Created by Lex on 19/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class Email: Mappable, Codable {
    
    var id: String! = ""
    var userId: String! = ""
    var name: String! = ""
    var verified: Bool! = false
    var createdAt: String! = ""
    var isCurrent: Bool! = false

    init(id: String, userId: String, name: String, verified: Bool, createdAt: String, isCurrent: Bool) {
        self.id = id
        self.userId = userId
        self.name = id
        self.verified = verified
        self.createdAt = createdAt
        self.isCurrent = isCurrent
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        name <- map["name"]
        verified <- map["verified"]
        createdAt <- map["createdAt"]
        isCurrent <- map["isCurrent"]
    }
}
