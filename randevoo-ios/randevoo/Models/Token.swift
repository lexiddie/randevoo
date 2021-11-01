//
//  Token.swift
//  randevoo
//
//  Created by Alexander on 25/1/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class Token: Mappable, Codable {
    
    var id: String! = ""
    var fcmToken: String! = ""
    var createdAt: String! = ""
    
    init(id: String, fcmToken: String, createdAt: String) {
        self.id = id
        self.fcmToken = fcmToken
        self.createdAt = createdAt
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        fcmToken <- map["fcmToken"]
        createdAt <- map["createdAt"]
    }
}
