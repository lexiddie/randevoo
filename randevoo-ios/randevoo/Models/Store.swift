//
//  Store.swift
//  randevoo
//
//  Created by Lex on 27/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class Store: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""
    var username: String! = ""
    var location: String! = ""
    var type: String! = ""
    var profileUrl: String! = ""
    
    init(id: String, name: String, username: String, location: String, type: String, profileUrl: String) {
        self.id = id
        self.name = name
        self.username = username
        self.location = location
        self.type = type
        self.profileUrl = profileUrl
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        username <- map["username"]
        location <- map["location"]
        type <- map["type"]
        profileUrl <- map["profileUrl"]
    }
}
