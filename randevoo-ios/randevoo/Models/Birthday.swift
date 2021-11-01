//
//  Birthday.swift
//  randevoo
//
//  Created by Lex on 12/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class Birthday: Mappable, Codable {
    
    var id: String! = ""
    var userId: String! = ""
    var date: String! = ""
    var createdAt: String! = ""
    var isCurrent: Bool! = false

    init(id: String, userId: String, date: String, createdAt: String, isCurrent: Bool! = false) {
        self.id = id
        self.userId = userId
        self.date = date
        self.createdAt = createdAt
        self.isCurrent = isCurrent
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        date <- map["date"]
        createdAt <- map["createdAt"]
        isCurrent <- map["isCurrent"]
    }
}

