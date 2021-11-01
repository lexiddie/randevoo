//
//  ListModel.swift
//  randevoo
//
//  Created by Xell on 10/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import Foundation
import ObjectMapper

class ListModel: Mappable, Codable {

    var id: String! = ""
    var userId: String! = ""
    var productId: String! = ""
    var variant: Variant!

    init(id: String, userId: String, productId: String, variant: Variant) {
        self.id = id
        self.userId = userId
        self.productId = productId
        self.variant = variant
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        productId <- map["productId"]
        variant <- map["variant"]
    }
}

