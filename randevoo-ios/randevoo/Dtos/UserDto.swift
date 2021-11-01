//
//  UserDto.swift
//  randevoo
//
//  Created by Lex on 27/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class UserDto: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""
    var username: String! = ""
    var location: String! = ""
    
    init(id: String, name: String, username: String, location: String) {
        self.id = id
        self.name = name
        self.username = username
        self.location = location
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["objectID"]
        name <- map["name"]
        username <- map["username"]
        location <- map["location"]
    }
}
