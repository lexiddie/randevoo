//
//  PersonalAccount.swift
//  randevoo
//
//  Created by Lex on 10/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class PersonalAccount: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""
    var username: String! = ""
    var profileUrl: String! = ""
    var bio: String! = ""
    var country: String! = ""
    var location: String! = ""
    var website: String! = ""
    var createdAt: String! = ""
    var isOnline: Bool! = false
    var isBanned: Bool! = false

    init(id: String, name: String, username: String, profileUrl: String = "", bio: String = "", country: String = "", location: String = "", website: String = "", createdAt: String, isOnline: Bool = false, isBanned: Bool = false) {
        self.id = id
        self.name = name
        self.username = username
        self.profileUrl = profileUrl
        self.bio = bio
        self.country = country
        self.location = location
        self.website = website
        self.createdAt = createdAt
        self.isOnline = isOnline
        self.isBanned = isBanned
    }   

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        username <- map["username"]
        profileUrl <- map["profileUrl"]
        bio <- map["bio"]
        country <- map["country"]
        location <- map["location"]
        website <- map["website"]
        createdAt <- map["createdAt"]
        isOnline <- map["isOnline"]
        isBanned <- map["isBanned"]
    }
    
    func getUser() -> User {
        return User(id: id, name: name, username: username, profileUrl: profileUrl, bio: bio, location: location, website: website, createdAt: createdAt)
    }
    
    func copy(with zone: NSZone? = nil) -> PersonalAccount {
        let copy = PersonalAccount(id: id, name: name, username: username, profileUrl: profileUrl, bio: bio, country: country, location: location, website: website, createdAt: createdAt, isOnline: isOnline, isBanned: isBanned)
        return copy
    }
}

