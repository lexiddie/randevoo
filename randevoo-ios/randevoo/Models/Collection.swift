//
//  Collection.swift
//  randevoo
//
//  Created by Lex on 27/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class Collection: Mappable, Codable {
    
    var id: String! = ""
    var name: String! = ""
    var photoUrl: String! = ""
    var products: [String] = []
    var bizName: String! = ""
    var bizProfileUrl: String! = ""
    var businessId: String! = ""
    var createdAt: String! = ""
    var isActive: Bool = true
    
    init(id: String, name: String, photoUrl: String, products: [String], bizName: String = "", bizProfileUrl: String = "", businessId: String, createdAt: String = "", isActive: Bool = true) {
        self.id = id
        self.name = name
        self.photoUrl = photoUrl
        self.products = products
        self.bizName = bizName
        self.bizProfileUrl = bizProfileUrl
        self.businessId = businessId
        self.createdAt = createdAt
        self.isActive = isActive
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["objectID"]
        name <- map["name"]
        photoUrl <- map["photoUrl"]
        products <- map["products"]
        bizName <- map["bizName"]
        bizProfileUrl <- map["bizProfileUrl"]
        businessId <- map["businessId"]
        createdAt <- map["createdAt"]
        isActive <- map["isActive"]
    }
}
