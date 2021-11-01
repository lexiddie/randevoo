//
//  StoreAccount.swift
//  randevoo
//
//  Created by Lex on 3/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class StoreAccount: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""
    var type: String! = ""
    var username: String! = ""
    var profileUrl: String! = ""
    var bio: String! = ""
    var country: String! = ""
    var location: String! = ""
    var website: String! = ""
    var createdAt: String! = ""
    var isVerified: Bool! = false
    var isBanned: Bool! = false

    init(id: String, name: String, type: String, username: String, profileUrl: String = "", bio: String = "", country: String, location: String, website: String = "", createdAt: String, isVerified: Bool = false, isBanned: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.username = username
        self.profileUrl = profileUrl
        self.bio = bio
        self.country = country
        self.location = location
        self.website = website
        self.createdAt = createdAt
        self.isVerified = isVerified
        self.isBanned = isBanned
    }
    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        type <- map["type"]
        username <- map["username"]
        profileUrl <- map["profileUrl"]
        bio <- map["bio"]
        country <- map["country"]
        location <- map["location"]
        website <- map["website"]
        createdAt <- map["createdAt"]
        isVerified <- map["isVerified"]
        isBanned <- map["isBanned"]
    }
    
}
