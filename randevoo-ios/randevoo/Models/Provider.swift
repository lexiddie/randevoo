//
//  Provider.swift
//  randevoo
//
//  Created by Lex on 19/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class Provider: Mappable, Codable {
    
    var id: String! = ""
    var userId: String! = ""
    var name: String! = ""
    var email: String! = ""
    var createdAt: String! = ""
    var isCurrent: Bool! = false

    init(id: String, userId: String, name: String = "Google", email: String, createdAt: String, isCurrent: Bool! = false) {
        self.id = id
        self.userId = userId
        self.name = name
        self.email = email
        self.createdAt = createdAt
        self.isCurrent = isCurrent
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        name <- map["name"]
        email <- map["email"]
        createdAt <- map["createdAt"]
        isCurrent <- map["isCurrent"]
    }
}

