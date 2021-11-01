//
//  Activity.swift
//  randevoo
//
//  Created by Lex on 10/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class Activity: Mappable, Codable {
    
    var id: String! = ""
    var senderId: String! = ""
    var receiverId: String! = ""
    var reservationId: String! = ""
    var content: String! = ""
    var createdAt: String! = ""
    var user: User! = User()
    
    init(id: String, senderId: String, receiverId: String, reservationId: String, content: String, createdAt: String) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.reservationId = reservationId
        self.content = content
        self.createdAt = createdAt
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        senderId <- map["senderId"]
        receiverId <- map["receiverId"]
        reservationId <- map["reservationId"]
        content <- map["content"]
        createdAt <- map["createdAt"]
        user <- map["user"]
    }
}

