//
//  iMessage.swift
//  randevoo
//
//  Created by Lex on 11/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class iMessage: Mappable, Codable {
    
    var id: String! = ""
    var type: String! = ""
    var content: String! = ""
    var senderId: String! = ""
    var receiverId: String! = ""
    var isRead: Bool! = false
    var createdAt: String! = ""
    
    init(id: String = "", type: String = "", content: String = "", senderId: String = "", receiverId: String = "", isRead: Bool = false, createdAt: String = Date().iso8601withFractionalSeconds) {
        self.id = id
        self.type = type
        self.content = content
        self.createdAt = createdAt
        self.senderId = senderId
        self.receiverId = receiverId
        self.isRead = isRead
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        content <- map["content"]
        senderId <- map["senderId"]
        receiverId <- map["receiverId"]
        isRead <- map["isRead"]
        createdAt <- map["createdAt"]
    }
    
    func getText(accountId: String) -> String {
        let isOwner = self.senderId == accountId ? true : false
        return self.type == "text" ? self.content : (
            isOwner ? "Sent a photo" : "You sent a photo")
    }
    
}
