//
//  User.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class User: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""
    var username: String! = ""
    var profileUrl: String! = ""
    var bio: String! = ""
    var location: String! = ""
    var website: String! = ""
    var createdAt: String! = ""

    init(id: String = "", name: String = "", username: String = "", profileUrl: String = "", bio: String = "", location: String = "", website: String = "", createdAt: String = "") {
        self.id = id
        self.name = name
        self.username = username
        self.profileUrl = profileUrl
        self.bio = bio
        self.location = location
        self.website = website
        self.createdAt = createdAt
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        username <- map["username"]
        profileUrl <- map["profileUrl"]
        bio <- map["bio"]
        location <- map["location"]
        website <- map["website"]
        createdAt <- map["createdAt"]
    }
}
