//
//  Chat.swift
//  randevoo
//
//  Created by Xell on 8/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class Chat: Mappable, Codable {
    
    var id: String! = ""
    var type: String! = ""
    var content: String! = ""
    var createdAt: String?
    var senderId: String! = ""
    var receiverId: String! = ""
    var isRead: Bool! = false
    var isNotify: Bool = false
    
    init(id: String, type: String, content: String, createdAt: String, senderId: String, receiverId: String, isRead: Bool, isNotify: Bool) {
        self.id = id
        self.type = type
        self.content = content
        self.createdAt = createdAt
        self.senderId = senderId
        self.receiverId = receiverId
        self.isRead = isRead
        self.isNotify = isNotify
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        content <- map["content"]
        createdAt <- map["createdAt"]
        senderId <- map["senderId"]
        receiverId <- map["receiverId"]
        isRead <- map["isRead"]
        isNotify <- map["isNotify"]
    }
}
