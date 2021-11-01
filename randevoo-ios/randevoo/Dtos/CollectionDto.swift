//
//  CollectionDto.swift
//  randevoo
//
//  Created by Lex on 27/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class CollectionDto: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""
    var photoUrl: String! = ""
    var products: [String] = []
    var businessId: String! = ""
    
    init(id: String, name: String, photoUrl: String, products: [String], businessId: String) {
        self.id = id
        self.name = name
        self.photoUrl = photoUrl
        self.products = products
        self.businessId = businessId
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["objectID"]
        name <- map["name"]
        photoUrl <- map["photoUrl"]
        products <- map["products"]
        businessId <- map["businessId"]
    }
}
