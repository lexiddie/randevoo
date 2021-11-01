//
//  Notification.swift
//  randevoo
//
//  Created by Xell on 7/3/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class Notification: Mappable, Codable {
    
    var content: String! = ""
    var messengerId: String! = ""
    var receiverId: String! = ""
    var senderId: String! = ""
    var reservationId: String! = ""
    
    init(content: String, messengerId: String, receiverId: String, senderId: String, reservationId: String) {
        self.content = content
        self.messengerId = messengerId
        self.receiverId = receiverId
        self.senderId = senderId
        self.reservationId = reservationId

    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        content <- map["content"]
        messengerId <- map["messengerId"]
        receiverId <- map["receiverId"]
        senderId <- map["senderId"]
        reservationId <- map["reservationId"]
    }
}

