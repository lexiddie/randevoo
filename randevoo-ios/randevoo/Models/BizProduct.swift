//
//  BizProduct.swift
//  randevoo
//
//  Created by Lex on 8/3/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class BizProduct: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""
    var price: Double! = 0.0
    var subcategoryId: String! = ""
    var description: String! = ""
    var photoUrl: String! = ""
    var variant: Variant!

    init(product: Product, variant: Variant) {
        self.id = product.id
        self.name = product.name
        self.price = product.price
        self.subcategoryId = product.subcategoryId
        self.description = product.description
        self.photoUrl = product.photoUrls[0]
        self.variant = variant
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        price <- map["price"]
        subcategoryId <- map["subcategoryId"]
        description <- map["description"]
        photoUrl <- map["photoUrl"]
        variant <- map["variant"]
    }
}

