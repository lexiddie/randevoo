//
//  SubcategoryDto.swift
//  randevoo
//
//  Created by Lex on 21/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class SubcategoryDto: Mappable, Codable {
    
    var id: String! = ""
    var categoryId: String! = ""
    var label: String! = ""
    var name: String! = ""
    var photoUrl: String! = ""
    var variations: [String] = []

    init(id: String, categoryId: String, label: String, name: String, photoUrl: String, variations: [String]) {
        self.id = id
        self.categoryId = categoryId
        self.label = label
        self.name = name
        self.photoUrl = photoUrl
        self.variations = variations
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        categoryId <- map["categoryId"]
        label <- map["label"]
        name <- map["name"]
        photoUrl <- map["photoUrl"]
        variations <- map["variations"]
    }
}

