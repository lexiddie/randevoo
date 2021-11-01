//
//  ListProduct.swift
//  randevoo
//
//  Created by Lex on 15/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class ListProduct: Mappable, Codable {
    
    var id: String!
    var businessId: String!
    var bizName: String! = ""
    var bizUsername: String! = ""
    var bizProfileUrl: String! = ""
    var bizLocation: String! = ""
    var bizGeoPoint: GeoPoint!
    var name: String!
    var price: Double! = 0.0
    var category: String!
    var subcategory: String!
    var photoUrl: String!

    init(id: String, businessId: String, bizName: String = "", bizUsername: String = "", bizProfileUrl: String = "", bizLocation: String = "", bizGeoPoint: GeoPoint = GeoPoint(), name: String, price: Double, category: String = "", subcategory: String = "", photoUrl: String) {
        self.id = id
        self.businessId = businessId
        self.bizName = bizName
        self.bizUsername = bizUsername
        self.bizProfileUrl = bizProfileUrl
        self.bizLocation = bizLocation
        self.bizGeoPoint = bizGeoPoint
        self.name = name
        self.price = price
        self.category = category
        self.subcategory = subcategory
        self.photoUrl = photoUrl
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        businessId <- map["businessId"]
        bizName <- map["bizName"]
        bizUsername <- map["bizUsername"]
        bizProfileUrl <- map["bizProfileUrl"]
        bizLocation <- map["bizLocation"]
        bizGeoPoint <- map["bizGeoPoint"]
        name <- map["name"]
        price <- map["price"]
        category <- map["category"]
        subcategory <- map["subcategory"]
        photoUrl <- map["photoUrl"]
    }
}

