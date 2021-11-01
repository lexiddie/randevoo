//
//  ProductDto.swift
//  randevoo
//
//  Created by Lex on 26/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class ProductDto: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""
    var price: Double! = 0.0
    var description: String! = ""
    var photoUrl: String! = ""
    var businessId: String! = ""
    var subcategoryId: String! = ""

    init(id: String, name: String, price: Double, description: String, photoUrl: String, businessId: String, subcategoryId: String) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.photoUrl = photoUrl
        self.businessId = businessId
        self.subcategoryId = subcategoryId
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["objectID"]
        name <- map["name"]
        price <- map["price"]
        description <- map["description"]
        photoUrl <- map["photoUrl"]
        businessId <- map["businessId"]
        subcategoryId <- map["subcategoryId"]
    }
}
