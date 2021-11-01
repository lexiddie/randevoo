//
//  RetailLocation.swift
//  randevoo
//
//  Created by Lex on 31/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class RetailLocation: Mappable, Codable {
    
    var id: String! = ""
    var businessId: String! = ""
    var firstAddress: String! = ""
    var secondAddress: String! = ""
    var city: String! = ""
    var region: String! = ""
    var postalCode: String! = ""
    var country: String! = ""
    var createdAt: String! = ""
    var isCurrent: Bool! = false

    init(id: String, businessId: String, firstAddress: String, secondAddress: String, city: String, region: String, postalCode: String, country: String, createdAt: String, isCurrent: Bool! = false) {
        self.id = id
        self.businessId = businessId
        self.firstAddress = firstAddress
        self.secondAddress = secondAddress
        self.city = city
        self.region = region
        self.postalCode = postalCode
        self.country = country
        self.createdAt = createdAt
        self.isCurrent = isCurrent
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        businessId <- map["businessId"]
        firstAddress <- map["firstAddress"]
        secondAddress <- map["secondAddress"]
        city <- map["city"]
        region <- map["region"]
        postalCode <- map["postalCode"]
        country <- map["country"]
        createdAt <- map["createdAt"]
        isCurrent <- map["isCurrent"]
    }
}

