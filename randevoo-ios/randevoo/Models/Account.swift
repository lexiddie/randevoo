//
//  Account.swift
//  randevoo
//
//  Created by Alexander on 30/1/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class Account: Mappable, Codable {
    
    var id: String! = ""
    var username: String! = ""
    var profileUrl: String! = ""
    var isPersonal: Bool! = false

    init(id: String, username: String, profileUrl: String, isPersonal: Bool) {
        self.id = id
        self.username = username
        self.profileUrl = profileUrl
        self.isPersonal = isPersonal
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
        profileUrl <- map["profileUrl"]
        isPersonal <- map["isPersonal"]
    }
}


