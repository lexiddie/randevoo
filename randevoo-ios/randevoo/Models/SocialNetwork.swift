//
//  Social.swift
//  randevoo
//
//  Created by Lex on 21/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class SocialNetwork: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""
    var username: String! = ""
    var createdAt: String! = ""
    var isCurrent: Bool! = false

    init(id: String, name: String = "Messenger", username: String, createdAt: String, isCurrent: Bool) {
        self.id = id
        self.name = name
        self.username = username
        self.createdAt = createdAt
        self.isCurrent = isCurrent
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        username <- map["username"]
        createdAt <- map["createdAt"]
        isCurrent <- map["isCurrent"]
    }
}

