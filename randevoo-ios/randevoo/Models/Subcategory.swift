//
//  Subcategory.swift
//  randevoo
//
//  Created by Lex on 6/9/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import ObjectMapper
import Cache

class Subcategory: Mappable, Codable {
    
    var id: String! = ""
    var category: Category!
    var label: String! = ""
    var name: String! = ""
    var photoUrl: String! = ""
    var variations: [Variation] = []
    var isSelected: Bool = false

    init(id: String, category: Category, label: String, name: String, photoUrl: String = "", variations: [Variation]) {
        self.id = id
        self.category = category
        self.label = label
        self.name = name
        self.photoUrl = photoUrl
        self.variations = variations
    }

    required init?(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        category <- map["category"]
        label <- map["label"]
        name <- map["name"]
        photoUrl <- map["photoUrl"]
        variations <- map["variations"]
    }
    
    func display() -> String {
        return "\(String(self.category.name)) \(String(self.name))"
    }
}

