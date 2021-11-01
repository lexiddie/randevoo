//
//  TempProduct.swift
//  randevoo
//
//  Created by Lex on 28/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class TempProduct: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""
    var imageUrl: String! = ""
    var price: Double! = 0.0

    init(id: String, name: String, imageUrl: String, price: Double) {
        self.id = id
        self.imageUrl = imageUrl
        self.price = price
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        imageUrl <- map["imageUrl"]
        price <- map["price"]
    }
}

