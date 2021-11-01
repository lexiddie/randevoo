//
//  Messenger.swift
//  randevoo
//
//  Created by Lex on 10/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import ObjectMapper
import AlamofireImage

class Messenger: Mappable, Codable {

    var id: String! = ""
    var members: [String] = []
    var recent: iMessage! = iMessage()
    var user: User! = User()
    var createdAt: String! = ""
    var isEmpty: Bool = true
    
    init(id: String, members: [String] = [], recent: iMessage = iMessage(), createdAt: String, isEmpty: Bool = true) {
        self.id = id
        self.members = members
        self.recent = recent
        self.createdAt = createdAt
        self.isEmpty = isEmpty
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        members <- map["members"]
        recent <- map["recent"]
        createdAt <- map["createdAt"]
        isEmpty <- map["isEmpty"]
    }
}

