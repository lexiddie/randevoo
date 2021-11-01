//
//  Save.swift
//  randevoo
//
//  Created by Xell on 18/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation
import ObjectMapper

class Save: Mappable, Codable {

    var id: String! = ""
    var productId: String! = ""
    var userId: String! = ""
    
    init(id: String,productId: String, userId: String) {
        self.id = id
        self.productId = productId
        self.userId = userId
    }
    
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        productId <- map["productId"]
        userId <- map["userId"]
    }
    
}
