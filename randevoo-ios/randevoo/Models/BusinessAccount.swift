//
//  BusinessAccount.swift
//  randevoo
//
//  Created by Lex on 10/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class BusinessAccount: Mappable, Codable {
    
    var id: String! = ""
    var userId: String! = ""
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
    var isOnline: Bool! = false
    var isBanned: Bool! = false

    init(id: String, userId: String, name: String, type: String, username: String, profileUrl: String = "", bio: String = "", country: String, location: String, website: String = "", createdAt: String, isVerified: Bool = false, isOnline: Bool = false, isBanned: Bool = false) {
        self.id = id
        self.userId = userId
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
        self.isOnline = isOnline
        self.isBanned = isBanned
    }
    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
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
        isOnline <- map["isOnline"]
        isBanned <- map["isBanned"]
    }
    
    func getUser() -> User {
        return User(id: id, name: name, username: username, profileUrl: profileUrl, bio: bio, location: location, website: website, createdAt: createdAt)
    }
    
    func getStoreAccount() -> StoreAccount {
        return StoreAccount(id: id, name: name, type: type, username: username, profileUrl: profileUrl, bio: bio, country: country, location: location, website: website, createdAt: createdAt, isVerified: isVerified)
    }
    
    func copy(with zone: NSZone? = nil) -> BusinessAccount {
        let copy = BusinessAccount(id: id, userId: userId, name: name, type: type, username: username, profileUrl: profileUrl, bio: bio, country: country, location: location, website: website, createdAt: createdAt, isVerified: isVerified, isOnline: isOnline, isBanned: isBanned)
        return copy
    }
    
}
