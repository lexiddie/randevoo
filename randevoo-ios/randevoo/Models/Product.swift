//
//  CreateProduct.swift
//  randevoo
//
//  Created by Lex on 24/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper

class Product: Mappable, Codable {
    
    var id: String! = ""
    var businessId: String! = ""
    var name: String! = ""
    var price: Double! = 0.0
    var subcategoryId: String! = ""
    var subcategory: Subcategory?
    var variants: [Variant] = []
    var available: Int! = 0
    var description: String! = ""
    var photoUrls: [String] = []
    var createdAt: String! = ""
    var isAvailable: Bool! = true
    var isBanned: Bool! = false
    var isActive: Bool! = true

    init(id: String, businessId: String, name: String, price: Double, subcategoryId: String, variants: [Variant], available: Int = 0, description: String, photoUrls: [String], createdAt: String, isAvailable: Bool = true, isBanned: Bool = false, isActive: Bool = true) {
        self.id = id
        self.businessId = businessId
        self.name = name
        self.price = price
        self.subcategoryId = subcategoryId
        self.available = available
        self.variants = variants
        self.description = description
        self.photoUrls = photoUrls
        self.createdAt = createdAt
        self.isAvailable = isAvailable
        self.isBanned = isBanned
        self.isActive = isActive
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        businessId <- map["businessId"]
        name <- map["name"]
        price <- map["price"]
        subcategoryId <- map["subcategoryId"]
        available <- map["available"]
        variants <- map["variants"]
        description <- map["description"]
        photoUrls <- map["photoUrls"]
        createdAt <- map["createdAt"]
        isAvailable <- map["isAvailable"]
        isBanned <- map["isBanned"]
        isActive <- map["isActive"]
    }
    
    func copy(with zone: NSZone? = nil) -> Product {
        let copy = Product(id: id, businessId: businessId, name: name, price: price, subcategoryId: subcategoryId, variants: variants, available: available, description: description, photoUrls: photoUrls, createdAt: createdAt, isAvailable: isAvailable, isBanned: isBanned, isActive: isActive)
        return copy
    }
    
    func getVariants(with zone: NSZone? = nil) -> [Variant] {
        var temps: [Variant] = []
        for i in self.variants {
            temps.append(i.copy())
        }
        return temps
    }
}

